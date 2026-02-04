/* r3d_animation.odin -- R3D Animation Module.
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
 * @brief Animation track storing keyframe times and values.
 *
 * Represents a single animated property (translation, rotation or scale).
 * Keys are sampled by time and interpolated at runtime.
 */
AnimationTrack :: struct {
    times:  [^]f32, ///< Keyframe times (sorted, in animation ticks).
    values: [^]f32, ///< Keyframe values (rl.Vector3 or rl.Quaternion).
    count:  i32,    ///< Number of keyframes.
}

/**
 * @brief Animation channel controlling a single bone.
 *
 * Contains animation tracks for translation, rotation and scale.
 * The sampled tracks are combined to produce the bone local transform.
 */
AnimationChannel :: struct {
    translation: AnimationTrack, ///< Translation track (rl.Vector3).
    rotation:    AnimationTrack, ///< Rotation track (rl.Quaternion).
    scale:       AnimationTrack, ///< Scale track (rl.Vector3).
    boneIndex:   i32,            ///< Index of the affected bone.
}

/**
 * @brief Represents a skeletal animation for a model.
 *
 * Contains all animation channels required to animate a skeleton.
 * Each channel corresponds to one bone and defines its transformation
 * (translation, rotation, scale) over time.
 */
Animation :: struct {
    channels:       [^]AnimationChannel, ///< Array of animation channels, one per animated bone.
    channelCount:   i32,                 ///< Total number of channels in this animation.
    ticksPerSecond: f32,                 ///< Playback rate; number of animation ticks per second.
    duration:       f32,                 ///< Total length of the animation, in ticks.
    boneCount:      i32,                 ///< Number of bones in the target skeleton.
    name:           [32]i8,              ///< Animation name (null-terminated string).
}

/**
 * @brief Represents a collection of skeletal animations sharing the same skeleton.
 *
 * Holds multiple animations that can be applied to compatible models or skeletons.
 * Typically loaded together from a single 3D model file (e.g., GLTF, FBX) containing several animation clips.
 */
AnimationLib :: struct {
    animations: ^Animation, ///< Array of animations included in this library.
    count:      i32,        ///< Number of animations contained in the library.
}

@(default_calling_convention="c", link_prefix="R3D_")
foreign lib {
    /**
     * @brief Loads animations from a model file.
     * @param filePath Path to the model file containing animations.
     * @param targetFrameRate Desired frame rate (FPS) for sampling the animations.
     * @return Pointer to an array of R3D_Animation, or NULL on failure.
     * @note Free the returned array using R3D_UnloadAnimationLib().
     */
    LoadAnimationLib :: proc(filePath: cstring) -> AnimationLib ---

    /**
     * @brief Loads animations from memory data.
     * @param data Pointer to memory buffer containing model animation data.
     * @param size Size of the buffer in bytes.
     * @param hint Hint on the model format (can be NULL).
     * @param targetFrameRate Desired frame rate (FPS) for sampling the animations.
     * @return Pointer to an array of R3D_Animation, or NULL on failure.
     * @note Free the returned array using R3D_UnloadAnimationLib().
     */
    LoadAnimationLibFromMemory :: proc(data: rawptr, size: u32, hint: cstring) -> AnimationLib ---

    /**
     * @brief Loads animations from an existing importer.
     * @param importer Importer instance containing animation data.
     * @return Pointer to an array of R3D_Animation, or NULL on failure.
     * @note Free the returned array using R3D_UnloadAnimationLib().
     */
    LoadAnimationLibFromImporter :: proc(importer: ^Importer) -> AnimationLib ---

    /**
     * @brief Releases all resources associated with an animation library.
     * @param animLib Animation library to unload.
     */
    UnloadAnimationLib :: proc(animLib: AnimationLib) ---

    /**
     * @brief Returns the index of an animation by name.
     * @param animLib Animation library to search.
     * @param name Name of the animation (case-sensitive).
     * @return Zero-based index if found, or -1 if not found.
     */
    GetAnimationIndex :: proc(animLib: AnimationLib, name: cstring) -> i32 ---

    /**
     * @brief Retrieves an animation by name.
     * @param animLib Animation library to search.
     * @param name Name of the animation (case-sensitive).
     * @return Pointer to the animation, or NULL if not found.
     */
    GetAnimation :: proc(animLib: AnimationLib, name: cstring) -> ^Animation ---
}

