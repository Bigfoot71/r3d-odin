/* r3d_skeleton.odin -- R3D Skeleton Module.
 *
 * Copyright (c) 2025 Le Juez Victor
 *
 * This software is provided 'as-is', without any express or implied warranty.
 * For conditions of distribution and use, see accompanying LICENSE file.
 */
package r3d

import rl "vendor:raylib"

when ODIN_OS == .Windows {
    foreign import lib {
        "windows/libr3d.a",
        "system:raylib",
        "system:assimp",
    }
} else when ODIN_OS == .Linux {
    foreign import lib {
        "linux/libr3d.a",
        "system:raylib",
        "system:assimp",
    }
} else when ODIN_OS == .Darwin {
    foreign import lib {
        "darwin/libr3d.a",
        "system:raylib",
        "system:assimp",
    }
}

/**
 * @brief Stores bone information for skeletal animation.
 *
 * Contains the bone name and the index of its parent bone.
 */
BoneInfo :: struct {
    name:   [32]i8, ///< Bone name (max 31 characters + null terminator).
    parent: i32,    ///< Index of the parent bone (-1 if root).
}

/**
 * @brief Represents a skeletal hierarchy used for skinning.
 *
 * Defines the bone structure, reference poses, and inverse bind matrices
 * required for skeletal animation. The skeleton provides both local and
 * global bind poses used during skinning and animation playback.
 */
Skeleton :: struct {
    bones:       [^]BoneInfo, ///< Array of bone descriptors defining the hierarchy and names.
    boneCount:   i32,         ///< Total number of bones in the skeleton.
    localBind:   [^]rl.Matrix,   ///< Bind pose matrices relative to parent
    modelBind:   [^]rl.Matrix,   ///< Bind pose matrices in model/global space
    invBind:     [^]rl.Matrix,   ///< Inverse bind matrices (model space) for skinning
    rootBind:    [16]f32,     ///< Root correction if local bind is not identity
    skinTexture: u32,         ///< rl.Texture ID that contains the bind pose for GPU skinning. This is a 1D rl.Texture RGBA16F 4*boneCount.
}

@(default_calling_convention="c", link_prefix="R3D_")
foreign lib {
    /**
     * @brief Loads a skeleton hierarchy from a 3D model file.
     *
     * Skeletons are automatically loaded when importing a model,
     * but can be loaded manually for advanced use cases.
     *
     * @param filePath Path to the model file containing the skeleton data.
     * @return Return the loaded R3D_Skeleton.
     */
    LoadSkeleton :: proc(filePath: cstring) -> Skeleton ---

    /**
     * @brief Loads a skeleton hierarchy from memory data.
     *
     * Allows manual loading of skeletons directly from a memory buffer.
     * Typically used for advanced or custom asset loading workflows.
     *
     * @param data Pointer to the memory buffer containing skeleton data.
     * @param size Size of the memory buffer in bytes.
     * @param hint Optional format hint (can be NULL).
     * @return Return the loaded R3D_Skeleton.
     */
    LoadSkeletonFromMemory :: proc(data: rawptr, size: u32, hint: cstring) -> Skeleton ---

    /**
     * @brief Loads a skeleton hierarchy from an existing importer.
     *
     * Extracts the skeleton data from a previously loaded importer instance.
     *
     * @param importer Importer instance to extract the skeleton from.
     * @return Return the loaded R3D_Skeleton.
     */
    LoadSkeletonFromImporter :: proc(importer: ^Importer) -> Skeleton ---

    /**
     * @brief Frees the memory allocated for a skeleton.
     *
     * @param skeleton R3D_Skeleton to destroy.
     */
    UnloadSkeleton :: proc(skeleton: Skeleton) ---

    /**
     * @brief Check if a skeleton is valid.
     *
     * Returns true if atleast the texBindPose is greater than zero.
     *
     * @param skeleton The skeleton to check.
     * @return true if valid, false otherwise.
     */
    IsSkeletonValid :: proc(skeleton: Skeleton) -> bool ---

    /**
     * @brief Returns the index of the bone with the given name.
     *
     * @param skeleton Skeleton to search in.
     * @param boneName Name of the bone to find.
     * @return Index of the bone, or a negative value if not found.
     */
    GetSkeletonBoneIndex :: proc(skeleton: Skeleton, boneName: cstring) -> i32 ---

    /**
     * @brief Returns a pointer to the bone with the given name.
     *
     * @param skeleton Skeleton to search in.
     * @param boneName Name of the bone to find.
     * @return Pointer to the bone, or NULL if not found.
     */
    GetSkeletonBone :: proc(skeleton: Skeleton, boneName: cstring) -> ^BoneInfo ---
}

