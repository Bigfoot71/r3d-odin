/* r3d_animation_tree.odin -- R3D Animation Tree Module.
 *
 * Copyright (c) 2025-2026 Le Juez Victor
 *
 * This software is provided 'as-is', without any express or implied warranty.
 * For conditions of distribution and use, see accompanying LICENSE file.
 */
package r3d

import rl "vendor:raylib"

when ODIN_OS == .Windows {
    foreign import lib {
        "windows/r3d.lib",
        "vendor:raylib/windows/raylib.lib",
        "windows/assimp-vc143-mt.lib",
        "vendor:zlib/libz.lib",
    }
} else when ODIN_OS == .Linux {
    foreign import lib {
        "linux/libr3d.a",
        "vendor:raylib/linux/libraylib.a",
        "linux/libassimp.a",
        "system:z",
        "system:stdc++",
        "system:dl",
        "system:pthread",
        "system:m",
    }
} else when ODIN_OS == .Darwin {
    foreign import lib {
        "darwin/libr3d.a",
        "vendor:raylib/macos/libraylib.a",
        "darwin/libassimp.a",
        "system:z",
        "system:c++",
    }
}

AnimationTreeNode :: struct {}
AnimationStmIndex :: i32

/**
 * @brief Callback type for manipulating the animation before it is used by the animation tree.
 *
 * @param animation Pointer to the processed animation.
 * @param state Current animation state.
 * @param boneIndex Index of the processed bone.
 * @param out Transformation of the processed bone.
 * @param userData Optional user-defined data passed when the callback was registered.
 */
AnimationNodeCallback :: proc "c" (animation: ^i32, state: i32, boneIndex: i32, out: ^i32, userData: rawptr)

/**
 * @brief Callback type for manipulating the final animation.
 *
 * @param player Pointer to the animation player used by the animation tree.
 * @param boneIndex Index of the processed bone.
 * @param out Transformation of the processed bone.
 * @param userData Optional user-defined data passed when the callback was registered.
 */
AnimationTreeCallback :: proc "c" (player: ^i32, boneIndex: i32, out: ^i32, userData: rawptr)

/**
 * @brief Types of operation modes for state machine edge.
 */
StmEdgeMode :: enum u32 {
    INSTANT = 0, ///< Switch to next state instantly, with respecting cross fade time.
    ONDONE  = 1, ///< Switch to next state when associated animation is done or looped with looper parameter set true.
}

/**
 * @brief Types of travel status for state machine edge.
 */
StmEdgeStatus :: enum u32 {
    ON   = 0, ///< Edge is traversable by travel function.
    AUTO = 1, ///< Edge is traversable automatically and by travel function.
    ONCE = 2, ///< Edge is traversable automatically and by travel function, but only once; edge status changes to nextStatus when traversed.
    OFF  = 3, ///< Edge is not traversable.
}

/**
 * @brief Bone mask for Blend2 and Add2 animation nodes.
 *
 * Bone mask structure, can by created by R3D_ComputeBoneMask.
 */
BoneMask :: struct {
    mask:      [8]i32, ///< Bit mask buffer for maximum of 256 bones (32bits * 8).
    boneCount: i32,    ///< Actual bones count.
}

/**
 * @brief Parameters for animation tree node Animation.
 *
 * Animation is a leaf node, holding the R3D_Animation structure.
 */
AnimationNodeParams :: struct {
    name:         [32]i8,                ///< Animation name (null-terminated string).
    state:        i32,                   ///< Animation state.
    looper:       i32,                   ///< Flag to control whether the animation is considered done when looped; yes when true.
    evalCallback: AnimationNodeCallback, ///< Callback function to receive and modify animation transformation before been used.
    evalUserData: rawptr,                ///< Optional user data pointer passed to the callback.
}

/**
 * @brief Parameters for animation tree node Blend2.
 *
 * Blend2 node blends channels of any two animation nodes together, with respecting optional bone mask.
 */
Blend2NodeParams :: struct {
    boneMask: ^BoneMask, ///< Pointer to bone mask structure, can be NULL; calculated by R3D_ComputeBoneMask().
    blend:    f32,       ///< Blend weight value, can be in interval from 0.0 to 1.0.
}

/**
 * @brief Parameters for animation tree node Add2.
 *
 * Add2 node adds channels of any two animation nodes together, with respecting optional bone mask.
 */
Add2NodeParams :: struct {
    boneMask: ^BoneMask, ///< Pointer to bone mask structure, can be NULL; calculated by R3D_ComputeBoneMask().
    weight:   f32,       ///< Add weight value, can be in interval from 0.0 to 1.0.
}

/**
 * @brief Parameters for animation tree node Switch.
 *
 * Switch node allows instant or blended/faded transition between any animation nodes connected to inputs.
 */
SwitchNodeParams :: struct {
    synced:      i32, ///< Flag to control input animation nodes synchronization; activated input is reset when false.
    activeInput: u32, ///< Active input zero-based index.
    xFadeTime:   f32, ///< Animation nodes cross fade blending time, in seconds.
}

/**
 * @brief Parameters for animation state machine edge.
 */
StmEdgeParams :: struct {
    mode:       StmEdgeMode,   ///< Operation mode.
    status:     StmEdgeStatus, ///< Current travel status.
    nextStatus: StmEdgeStatus, ///< Travel status used after machine traversed through this edge with status set to R3D_STM_EDGE_ONCE.
    xFadeTime:  f32,           ///< Cross fade blending time between connected animation nodes, in seconds.
}

/**
 * @brief Manages a tree structure of animation nodes.
 *
 * Animation tree allows to define complex logic for switching and blending animations of
 * associated animation player. It supports 5 different animation node types: Animation, Blend2, Add2,
 * Switch and State Machine. It also fully supports root motion and bone masking in Blend2/Add2.
 */
AnimationTree :: struct {
    player:          i32,                   ///< Animation player and skeleton used by all animation nodes.
    rootNode:        ^AnimationTreeNode,    ///< Pointer to root animation node of the tree.
    nodePool:        ^AnimationTreeNode,    ///< Animation node pool of size nodePoolMaxSize.
    nodePoolSize:    u32,                   ///< Current animation node pool size.
    nodePoolMaxSize: u32,                   ///< Maximum number of animation nodes, defined during load.
    rootBone:        i32,                   ///< Optional root bone index, -1 if not defined.
    updateCallback:  AnimationTreeCallback, ///< Callback function to receive and modify final animation transformation.
    updateUserData:  rawptr,                ///< Optional user data pointer passed to the callback.
}

@(default_calling_convention="c", link_prefix="R3D_")
foreign lib {
    /**
     * @brief Releases all resources used by an animation tree, including all animation nodes.
     *
     * @param tree Animation tree to unload.
     */
    UnloadAnimationTree :: proc(tree: AnimationTree) -> i32 ---

    /**
     * @brief Updates the animation tree: calculates blended pose, sets and uploads the pose through associated animation player.
     *
     * @param tree Animation tree.
     * @param dt Delta time in seconds.
     */
    UpdateAnimationTree :: proc(tree: ^AnimationTree, dt: f32) -> i32 ---

    /**
     * @brief Updates the animation tree: calculates blended pose, sets and uploads the pose through associated animation player.
     *
     * Set the rootMotion and/or rootDistance pointers to get root motion information.
     * Divide rootMotion translation vector by dt to get root bone speed.
     *
     * @param tree Animation tree.
     * @param dt Delta time in seconds.
     * @param rootMotion Pointer to root bone motion transformation.
     * @param rootDistance Pointer to transformation containing root bone distance from rest pose.
     */
    UpdateAnimationTreeEx :: proc(tree: ^AnimationTree, dt: f32, rootMotion: ^i32, rootDistance: ^i32) -> i32 ---

    /**
     * @brief Sets root animation node of the animation tree.
     *
     * @param tree Animation tree.
     * @param node Root animation node.
     */
    AddRootAnimationNode :: proc(tree: ^AnimationTree, node: ^AnimationTreeNode) -> i32 ---

    /**
     * @brief Sets parameters of animation node Animation.
     *
     * @param node Animation node of type Animation.
     * @param params New parameters.
     */
    SetAnimationNodeParams :: proc(node: ^AnimationTreeNode, params: AnimationNodeParams) -> i32 ---

    /**
     * @brief Sets parameters of animation node Blend2.
     *
     * @param node Animation node of type Blend2.
     * @param params New parameters.
     */
    SetBlend2NodeParams :: proc(node: ^AnimationTreeNode, params: Blend2NodeParams) -> i32 ---

    /**
     * @brief Sets parameters of animation node Add2.
     *
     * @param node Animation node of type Add2.
     * @param params New parameters.
     */
    SetAdd2NodeParams :: proc(node: ^AnimationTreeNode, params: Add2NodeParams) -> i32 ---

    /**
     * @brief Sets parameters of animation node Switch.
     *
     * @param node Animation node of type Switch.
     * @param params New parameters.
     */
    SetSwitchNodeParams :: proc(node: ^AnimationTreeNode, params: SwitchNodeParams) -> i32 ---

    /**
     * @brief Sets parameters of State Machine edge.
     *
     * @param node Animation node of type State Machine (Stm).
     * @param edgeIndex Index of the State Machine edge.
     * @param params New parameters of the edge.
     */
    SetStmNodeEdgeParams :: proc(node: ^AnimationTreeNode, edgeIndex: AnimationStmIndex, params: StmEdgeParams) -> i32 ---

    /**
     * @brief Sets travel path inside State Machine, from current state to target.
     *
     * If travel path is not found, target is set as current state instantly (teleport).
     *
     * @param node Animation node of type State Machine.
     * @param targetStateIndex Index of the targeted state.
     */
    TravelToStmState :: proc(node: ^AnimationTreeNode, targetStateIndex: AnimationStmIndex) -> i32 ---
}

