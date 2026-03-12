/* r3d_animation_player.odin -- R3D Animation Player Module.
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
        "/macos/libr3d.a",
        "vendor:raylib/macos/libraylib.a",
        "/macos/libassimp.a",
        "system:z",
        "system:c++",
    }
}

/**
 * @brief Types of events that an animation player can emit.
 */
AnimationEvent :: enum u32 {
    FINISHED = 0, ///< Animation has finished playing (non-looping).
    LOOPED   = 1, ///< Animation has completed a loop.
}

/**
 * @brief Callback type for receiving animation events.
 *
 * @param player Pointer to the animation player emitting the event.
 * @param eventType Type of the event (finished, looped).
 * @param animIndex Index of the animation triggering the event.
 * @param userData Optional user-defined data passed when the callback was registered.
 */
AnimationEventCallback :: proc "c" (player: ^AnimationPlayer, eventType: AnimationEvent, animIndex: i32, userData: rawptr)

/**
 * @brief Describes the playback state of a single animation within a player.
 *
 * Tracks the current time, speed, play/pause state, and looping behavior.
 */
AnimationState :: struct {
    currentTime: f32,  ///< Current playback time in animation ticks.
    speed:       f32,  ///< Playback speed; can be negative for reverse playback.
    play:        bool, ///< Whether the animation is currently playing.
    loop:        bool, ///< True to enable looping playback.
}

// ========================================
// FORWARD DECLARATIONS
// ========================================
AnimationPlayer :: struct {
    animLib:         AnimationLib,           ///< Animation library providing the available animations.
    skeleton:        Skeleton,               ///< Skeleton to animate.
    states:          [^]AnimationState,      ///< Array of animation states, one per animation.
    activeAnimIndex: i32,                    ///< Index of the current animation.
    localPose:       [^]rl.Matrix,              ///< Array of bone transforms representing the blended local pose.
    modelPose:       [^]rl.Matrix,              ///< Array of bone transforms in model space, obtained by hierarchical accumulation.
    skinBuffer:      [^]rl.Matrix,              ///< Array of final skinning matrices (invBind * modelPose), sent to the GPU.
    skinTexture:     u32,                    ///< GPU texture ID storing the skinning matrices as a 1D RGBA16F texture.
    eventCallback:   AnimationEventCallback, ///< Callback function to receive animation events.
    eventUserData:   rawptr,                 ///< Optional user data pointer passed to the callback.
}

@(default_calling_convention="c", link_prefix="R3D_")
foreign lib {
    /**
     * @brief Creates an animation player for a skeleton and animation library.
     *
     * Allocates memory for animation states and pose buffers.
     *
     * @param skeleton Skeleton to animate.
     * @param animLib Animation library providing animations.
     * @return Newly created animation player, or a zeroed struct on failure.
     */
    LoadAnimationPlayer :: proc(skeleton: Skeleton, animLib: AnimationLib) -> AnimationPlayer ---

    /**
     * @brief Releases all resources used by an animation player.
     *
     * @param player Animation player to unload.
     */
    UnloadAnimationPlayer :: proc(player: AnimationPlayer) ---

    /**
     * @brief Checks whether an animation player is valid.
     *
     * @param player Animation player to check.
     * @return true if valid, false otherwise.
     */
    IsAnimationPlayerValid :: proc(player: AnimationPlayer) -> bool ---

    /**
     * @brief Returns whether an animation is currently playing.
     *
     * @param player Animation player.
     * @return true if playing, false otherwise.
     */
    IsAnimationPlaying :: proc(player: AnimationPlayer) -> bool ---

    /**
     * @brief Starts playback of the specified animation.
     *
     * @param player Animation player.
     * @param animIndex Index of the animation to play.
     */
    PlayAnimation :: proc(player: ^AnimationPlayer, animIndex: i32) ---

    /**
     * @brief Pauses the current animation.
     *
     * @param player Animation player.
     * @param animIndex Index of the animation to pause.
     */
    PauseAnimation :: proc(player: ^AnimationPlayer) ---

    /**
     * @brief Stops the current animation and clamps its time.
     *
     * @param player Animation player.
     * @param animIndex Index of the animation to stop.
     */
    StopAnimation :: proc(player: ^AnimationPlayer) ---

    /**
     * @brief Rewinds the animation to the start or end depending on playback direction.
     *
     * @param player Animation player.
     * @param animIndex Index of the animation to rewind.
     */
    RewindAnimation :: proc(player: ^AnimationPlayer) ---

    /**
     * @brief Gets the current playback time of an animation.
     *
     * @param player Animation player.
     * @param animIndex Index of the animation.
     * @return Current time in animation ticks.
     */
    GetAnimationTime :: proc(player: AnimationPlayer, animIndex: i32) -> f32 ---

    /**
     * @brief Sets the current playback time of an animation.
     *
     * @param player Animation player.
     * @param animIndex Index of the animation.
     * @param time Time in animation ticks.
     */
    SetAnimationTime :: proc(player: ^AnimationPlayer, animIndex: i32, time: f32) ---

    /**
     * @brief Gets the playback speed of an animation.
     *
     * @param player Animation player.
     * @param animIndex Index of the animation.
     * @return Current speed (may be negative for reverse playback).
     */
    GetAnimationSpeed :: proc(player: AnimationPlayer, animIndex: i32) -> f32 ---

    /**
     * @brief Sets the playback speed of an animation.
     *
     * Negative values play the animation backwards. If setting a negative speed
     * on a stopped animation, consider calling RewindAnimation() to start at the end.
     *
     * @param player Animation player.
     * @param animIndex Index of the animation.
     * @param speed Playback speed.
     */
    SetAnimationSpeed :: proc(player: ^AnimationPlayer, animIndex: i32, speed: f32) ---

    /**
     * @brief Gets whether the animation is set to loop.
     *
     * @param player Animation player.
     * @param animIndex Index of the animation.
     * @return True if looping is enabled.
     */
    GetAnimationLoop :: proc(player: AnimationPlayer, animIndex: i32) -> bool ---

    /**
     * @brief Enables or disables looping for the animation.
     *
     * @param player Animation player.
     * @param animIndex Index of the animation.
     * @param loop True to enable looping.
     */
    SetAnimationLoop :: proc(player: ^AnimationPlayer, animIndex: i32, loop: bool) ---

    /**
     * @brief Advances the time of the current animation.
     *
     * Updates animation timer based on speed and delta time.
     * Does NOT recalculate the skeleton pose.
     *
     * @param player Animation player.
     * @param dt Delta time in seconds.
     */
    AdvanceAnimationTime :: proc(player: ^AnimationPlayer, dt: f32) ---

    /**
     * @brief Computes the local-space transform of each bone for the current animation.
     *
     * Samples and interpolates the current animation keyframes at the current playback time,
     * and stores the resulting bone transforms in local space into @p player->localPose.
     * Does NOT advance animation time, and does NOT compute model-space transforms.
     *
     * @param player Animation player whose local pose will be updated.
     */
    ComputeAnimationLocalPose :: proc(player: ^AnimationPlayer) ---

    /**
     * @brief Computes the model-space transform of each bone from the current local pose.
     *
     * Traverses the bone hierarchy and accumulates local transforms into model-space matrices,
     * stored into @p player->modelPose. This assumes @p player->localPose is already up-to-date.
     * Does NOT sample animation keyframes, and does NOT advance animation time.
     *
     * @param player Animation player whose model pose will be updated.
     */
    ComputeAnimationModelPose :: proc(player: ^AnimationPlayer) ---

    /**
     * @brief Computes both the local and model-space transforms for the current animation.
     *
     * Equivalent to calling R3D_ComputeAnimationLocalPose() followed by R3D_ComputeAnimationModelPose().
     * Does NOT advance animation time.
     *
     * @param player Animation player whose local and model poses will be updated.
     */
    ComputeAnimationPose :: proc(player: ^AnimationPlayer) ---

    /**
     * @brief Computes the final skinning matrices and uploads them to the GPU.
     *
     * Multiplies each bone's model-space transform by its inverse bind matrix to produce
     * the skinning matrices, then uploads them to the GPU skin texture.
     * This assumes @p player->modelPose is already up-to-date.
     *
     * @param player Animation player whose skinning matrices will be uploaded.
     */
    UploadAnimationPose :: proc(player: ^AnimationPlayer) ---

    /**
     * @brief Updates the animation player: calculates and upload the current pose pose, then advances time.
     *
     * Equivalent to calling R3D_ComputeAnimationLocalPose() followed by
     * R3D_ComputeAnimationModelPose() and R3D_AdvanceAnimationTime().
     *
     * @param player Animation player.
     * @param dt Delta time in seconds.
     */
    UpdateAnimationPlayer :: proc(player: ^AnimationPlayer, dt: f32) ---
}

