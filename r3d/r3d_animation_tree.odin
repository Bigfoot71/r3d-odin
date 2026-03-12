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
    }
} else when ODIN_OS == .Linux {
    foreign import lib {
        "linux/libr3d.a",
    }
} else when ODIN_OS == .Darwin {
    foreign import lib {
        "/macos/libr3d.a",
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
AnimationNodeCallback :: proc "c" (animation: ^Animation, state: AnimationState, boneIndex: i32, out: ^rl.Transform, userData: rawptr)

/**
 * @brief Callback type for manipulating the final animation.
 *
 * @param player Pointer to the animation player used by the animation tree.
 * @param boneIndex Index of the processed bone.
 * @param out Transformation of the processed bone.
 * @param userData Optional user-defined data passed when the callback was registered.
 */
AnimationTreeCallback :: proc "c" (player: ^AnimationPlayer, boneIndex: i32, out: ^rl.Transform, userData: rawptr)

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
    state:        AnimationState,        ///< Animation state.
    looper:       bool,                  ///< Flag to control whether the animation is considered done when looped; yes when true.
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
    synced:      bool, ///< Flag to control input animation nodes synchronization; activated input is reset when false.
    activeInput: i32,  ///< Active input zero-based index.
    xFadeTime:   f32,  ///< Animation nodes cross fade blending time, in seconds.
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
    player:          AnimationPlayer,       ///< Animation player and skeleton used by all animation nodes.
    rootNode:        ^AnimationTreeNode,    ///< Pointer to root animation node of the tree.
    nodePool:        ^AnimationTreeNode,    ///< Animation node pool of size nodePoolMaxSize.
    nodePoolSize:    i32,                   ///< Current animation node pool size.
    nodePoolMaxSize: i32,                   ///< Maximum number of animation nodes, defined during load.
    rootBone:        i32,                   ///< Optional root bone index, -1 if not defined.
    updateCallback:  AnimationTreeCallback, ///< Callback function to receive and modify final animation transformation.
    updateUserData:  rawptr,                ///< Optional user data pointer passed to the callback.
}

@(default_calling_convention="c", link_prefix="R3D_")
foreign lib {
    /**
     * @brief Creates an animation tree using given animation player.
     *
     * Allocates memory for animation nodes pool.
     *
     * @param player Animation player used by the animation tree.
     * @param maxSize Size of the animation nodes pool; maximum number of animation nodes in the tree.
     * @return Newly created animation tree, or a zeroed struct on failure.
     */
    LoadAnimationTree :: proc(player: AnimationPlayer, maxSize: i32) -> AnimationTree ---

    /**
     * @brief Creates an animation tree using given animation player, with optional root motion support.
     *
     * Allocates memory for animation nodes pool and sets root bone index for root motion.
     *
     * @param player Animation player used by the animation tree.
     * @param maxSize Size of the animation nodes pool; maximum number of animation nodes in the tree.
     * @param rootBone Root bone index; set -1 to disable root motion.
     * @return Newly created animation tree, or a zeroed struct on failure.
     */
    LoadAnimationTreeEx :: proc(player: AnimationPlayer, maxSize: i32, rootBone: i32) -> AnimationTree ---

    /**
     * @brief Creates an animation tree using given animation player, with optional root motion support and callback.
     *
     * Allocates memory for animation nodes pool, sets root bone index and update callback.
     *
     * @param player Animation player used by the animation tree.
     * @param maxSize Size of the animation nodes pool; maximum number of animation nodes in the tree.
     * @param rootBone Root bone index; set -1 to disable root motion.
     * @param updateCallback Callback function pointer to receive and modify final animation transformation, can be NULL.
     * @param updateUserData User data pointer passed to the callback, can be NULL.
     * @return Newly created animation tree, or a zeroed struct on failure.
     */
    LoadAnimationTreePro :: proc(player: AnimationPlayer, maxSize: i32, rootBone: i32, updateCallback: AnimationTreeCallback, updateUserData: rawptr) -> AnimationTree ---

    /**
     * @brief Releases all resources used by an animation tree, including all animation nodes.
     *
     * @param tree Animation tree to unload.
     */
    UnloadAnimationTree :: proc(tree: AnimationTree) ---

    /**
     * @brief Updates the animation tree: calculates blended pose, sets and uploads the pose through associated animation player.
     *
     * @param tree Animation tree.
     * @param dt Delta time in seconds.
     */
    UpdateAnimationTree :: proc(tree: ^AnimationTree, dt: f32) ---

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
    UpdateAnimationTreeEx :: proc(tree: ^AnimationTree, dt: f32, rootMotion: ^rl.Transform, rootDistance: ^rl.Transform) ---

    /**
     * @brief Sets root animation node of the animation tree.
     *
     * @param tree Animation tree.
     * @param node Root animation node.
     */
    AddRootAnimationNode :: proc(tree: ^AnimationTree, node: ^AnimationTreeNode) ---

    /**
     * @brief Connects two animation nodes of animation tree hierarchy.
     *
     * @param parent Parent animation node.
     * @param node Child animation node.
     * @param inputIndex Index of the parent node input used for connection.
     * @return True on success; false if parent node or inputIndex is invalid.
     */
    AddAnimationNode :: proc(parent: ^AnimationTreeNode, node: ^AnimationTreeNode, inputIndex: i32) -> bool ---

    /**
     * @brief Creates animation node of type Animation.
     *
     * Animation is a leaf node, holding the R3D_Animation structure.
     *
     * @param tree Animation tree.
     * @param params Animation node initial parameters.
     * @return Pointer to created animation node; NULL if maximum number of nodes was exceeded or animation name is not found.
     */
    CreateAnimationNode :: proc(tree: ^AnimationTree, params: AnimationNodeParams) -> ^AnimationTreeNode ---

    /**
     * @brief Creates animation node of type Animation, optionally sets animation currentTime.
     *
     * Animation is a leaf node, holding the R3D_Animation structure.
     *
     * @param tree Animation tree.
     * @param params Animation node initial parameters.
     * @param setTime Flag to set currentTime value based on animation speed; useful for animations with negative speed in State Machine.
     * @return Pointer to created animation node; NULL if maximum number of nodes was exceeded or animation name is not found.
     */
    CreateAnimationNodeEx :: proc(tree: ^AnimationTree, params: AnimationNodeParams, setTime: bool) -> ^AnimationTreeNode ---

    /**
     * @brief Creates animation node of type Blend2.
     *
     * Blend2 node blends channels of any two animation nodes together, with respecting optional bone mask.
     *
     * @param tree Animation tree.
     * @param params Blend2 node initial parameters.
     * @return Pointer to created animation node; NULL if maximum number of nodes was exceeded.
     */
    CreateBlend2Node :: proc(tree: ^AnimationTree, params: Blend2NodeParams) -> ^AnimationTreeNode ---

    /**
     * @brief Creates animation node of type Add2.
     *
     * Add2 node adds channels of any two animation nodes together, with respecting optional bone mask.
     *
     * @param tree Animation tree.
     * @param params Add2 node initial parameters.
     * @return Pointer to created animation node; NULL if maximum number of nodes was exceeded.
     */
    CreateAdd2Node :: proc(tree: ^AnimationTree, params: Add2NodeParams) -> ^AnimationTreeNode ---

    /**
     * @brief Creates animation node of type Switch.
     *
     * Switch node allows instant or blended/faded transition between any animation nodes connected to inputs.
     *
     * @param tree Animation tree.
     * @param inputCount Number of available inputs.
     * @param params Switch node initial parameters.
     * @return Pointer to created animation node; NULL if maximum number of nodes was exceeded.
     */
    CreateSwitchNode :: proc(tree: ^AnimationTree, inputCount: i32, params: SwitchNodeParams) -> ^AnimationTreeNode ---

    /**
     * @brief Creates animation node of type State Machine (Stm).
     *
     * Stm node allows to create a state machine graph of any animation nodes.
     *
     * @param tree Animation tree.
     * @param statesCount Maximum number of states in the state machine.
     * @param edgesCount Maximum number of edges in the state machine.
     * @return Pointer to created animation node; NULL if maximum number of nodes was exceeded.
     */
    CreateStmNode :: proc(tree: ^AnimationTree, statesCount: i32, edgesCount: i32) -> ^AnimationTreeNode ---

    /**
     * @brief Creates animation node of type State Machine (Stm), with option to disable travel feature (enabled by default).
     *
     * @param tree Animation tree.
     * @param statesCount Maximum number of states in the state machine.
     * @param edgesCount Maximum number of edges in the state machine.
     * @param enableTravel Flag to enable or disable travel feature; enabled when set true.
     * @return Pointer to created animation node; NULL if maximum number of nodes was exceeded.
     */
    CreateStmNodeEx :: proc(tree: ^AnimationTree, statesCount: i32, edgesCount: i32, enableTravel: bool) -> ^AnimationTreeNode ---

    /**
     * @brief Creates animation node of type State Machine Stop/Done (StmX).
     *
     * StmX is a helper animation node, that allows stopping state machine evaluation in the current update.
     * Sets animation node done status of the state machine to true.
     *
     * @param tree Animation tree.
     * @param nestedNode Actual animation node with animation channels.
     * @return Pointer to created animation node; NULL if maximum number of nodes was exceeded.
     */
    CreateStmXNode :: proc(tree: ^AnimationTree, nestedNode: ^AnimationTreeNode) -> ^AnimationTreeNode ---

    /**
     * @brief Creates state in a State Machine animation node.
     *
     * @param stmNode Animation node of type State Machine.
     * @param stateNode Associated animation node of the state.
     * @param outEdgesCount Number of output edges of the state.
     * @return Index of created state; -1 if maximum number of states was exceeded.
     */
    CreateStmNodeState :: proc(stmNode: ^AnimationTreeNode, stateNode: ^AnimationTreeNode, outEdgesCount: i32) -> AnimationStmIndex ---

    /**
     * @brief Creates edge in a State Machine animation node.
     *
     * @param stmNode Animation node of type State Machine.
     * @param beginStateIndex Index of state connected to the edge beginning.
     * @param endStateIndex Index of state connected to the edge end.
     * @param params Edge initial parameters.
     * @return Index of created edge; -1 if maximum number of edges was exceeded.
     */
    CreateStmNodeEdge :: proc(stmNode: ^AnimationTreeNode, beginStateIndex: AnimationStmIndex, endStateIndex: AnimationStmIndex, params: StmEdgeParams) -> AnimationStmIndex ---

    /**
     * @brief Sets parameters of animation node Animation.
     *
     * @param node Animation node of type Animation.
     * @param params New parameters.
     */
    SetAnimationNodeParams :: proc(node: ^AnimationTreeNode, params: AnimationNodeParams) ---

    /**
     * @brief Gets parameters of animation node Animation.
     *
     * @param node Animation node of type Animation.
     * @return Current parameters.
     */
    GetAnimationNodeParams :: proc(node: ^AnimationTreeNode) -> AnimationNodeParams ---

    /**
     * @brief Sets parameters of animation node Blend2.
     *
     * @param node Animation node of type Blend2.
     * @param params New parameters.
     */
    SetBlend2NodeParams :: proc(node: ^AnimationTreeNode, params: Blend2NodeParams) ---

    /**
     * @brief Gets parameters of animation node Blend2.
     *
     * @param node Animation node of type Blend2.
     * @return Current parameters.
     */
    GetBlend2NodeParams :: proc(node: ^AnimationTreeNode) -> Blend2NodeParams ---

    /**
     * @brief Sets parameters of animation node Add2.
     *
     * @param node Animation node of type Add2.
     * @param params New parameters.
     */
    SetAdd2NodeParams :: proc(node: ^AnimationTreeNode, params: Add2NodeParams) ---

    /**
     * @brief Gets parameters of animation node Add2.
     *
     * @param node Animation node of type Add2.
     * @return Current parameters.
     */
    GetAdd2NodeParams :: proc(node: ^AnimationTreeNode) -> Add2NodeParams ---

    /**
     * @brief Sets parameters of animation node Switch.
     *
     * @param node Animation node of type Switch.
     * @param params New parameters.
     */
    SetSwitchNodeParams :: proc(node: ^AnimationTreeNode, params: SwitchNodeParams) ---

    /**
     * @brief Gets parameters of animation node Switch.
     *
     * @param node Animation node of type Switch.
     * @return Current parameters.
     */
    GetSwitchNodeParams :: proc(node: ^AnimationTreeNode) -> SwitchNodeParams ---

    /**
     * @brief Sets parameters of State Machine edge.
     *
     * @param node Animation node of type State Machine (Stm).
     * @param edgeIndex Index of the State Machine edge.
     * @param params New parameters of the edge.
     */
    SetStmNodeEdgeParams :: proc(node: ^AnimationTreeNode, edgeIndex: AnimationStmIndex, params: StmEdgeParams) ---

    /**
     * @brief Gets parameters of State Machine edge.
     *
     * @param node Animation node of type State Machine.
     * @param edgeIndex Index of the State Machine edge.
     * @return Current parameters of the edge.
     */
    GetStmNodeEdgeParams :: proc(node: ^AnimationTreeNode, edgeIndex: AnimationStmIndex) -> StmEdgeParams ---

    /**
     * @brief Gets active state index of State Machine.
     *
     * @param node Animation node of type State Machine.
     * @return Index of current active state.
     */
    GetStmStateActiveIndex :: proc(node: ^AnimationTreeNode) -> AnimationStmIndex ---

    /**
     * @brief Sets travel path inside State Machine, from current state to target.
     *
     * If travel path is not found, target is set as current state instantly (teleport).
     *
     * @param node Animation node of type State Machine.
     * @param targetStateIndex Index of the targeted state.
     */
    TravelToStmState :: proc(node: ^AnimationTreeNode, targetStateIndex: AnimationStmIndex) ---

    /**
     * @brief Computes bone mask from list of bone names.
     *
     * Only listed bones will be included in evaluation of animation node with this bone mask.
     * Can be used in Blend2 and Add2 animation nodes.
     *
     * @param skeleton Skeleton of associated animation player.
     * @param boneNames Array of pointers to null-terminated strings with bone names.
     * @param boneNameCount Count of strings in boneNames array.
     * @return Calculated bone mask, or zeroed structure on failure.
     */
    ComputeBoneMask :: proc(skeleton: ^Skeleton, boneNames: [^]cstring, boneNameCount: i32) -> BoneMask ---
}

