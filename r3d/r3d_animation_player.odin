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
 * Tracks the current time, blending weight, speed, play/pause state, and looping behavior.
 */
AnimationState :: struct {
    currentTime: f32,  ///< Current playback time in animation ticks.
    weight:      f32,  ///< Blending weight; any positive value is valid.
    speed:       f32,  ///< Playback speed; can be negative for reverse playback.
    play:        bool, ///< Whether the animation is currently playing.
    loop:        bool, ///< True to enable looping playback.
}

// ========================================
// FORWARD DECLARATIONS
// ========================================
AnimationPlayer :: struct {
    states:        [^]AnimationState,      ///< Array of active animation states, one per animation.
    animLib:       AnimationLib,           ///< Animation library providing the available animations.
    skeleton:      Skeleton,               ///< Skeleton to animate.
    localPose:     [^]rl.Matrix,              ///< Array of bone transforms representing the blended local pose.
    modelPose:     [^]rl.Matrix,              ///< Array of bone transforms in model space, obtained by hierarchical accumulation.
    skinBuffer:    [^]rl.Matrix,              ///< Array of final skinning matrices (invBind * modelPose), sent to the GPU.
    skinTexture:   u32,                    ///< GPU texture ID storing the skinning matrices as a 1D RGBA16F texture.
    eventCallback: AnimationEventCallback, ///< Callback function to receive animation events.
    eventUserData: rawptr,                 ///< Optional user data pointer passed to the callback.
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
     * @brief Returns whether a given animation is currently playing.
     *
     * @param player Animation player.
     * @param animIndex Index of the animation.
     * @return true if playing, false otherwise.
     */
    IsAnimationPlaying :: proc(player: AnimationPlayer, animIndex: i32) -> bool ---

    /**
     * @brief Starts playback of the specified animation.
     *
     * @param player Animation player.
     * @param animIndex Index of the animation to play.
     */
    PlayAnimation :: proc(player: ^AnimationPlayer, animIndex: i32) ---

    /**
     * @brief Pauses the specified animation.
     *
     * @param player Animation player.
     * @param animIndex Index of the animation to pause.
     */
    PauseAnimation :: proc(player: ^AnimationPlayer, animIndex: i32) ---

    /**
     * @brief Stops the specified animation and clamps its time.
     *
     * @param player Animation player.
     * @param animIndex Index of the animation to stop.
     */
    StopAnimation :: proc(player: ^AnimationPlayer, animIndex: i32) ---

    /**
     * @brief Rewinds the animation to the start or end depending on playback direction.
     *
     * @param player Animation player.
     * @param animIndex Index of the animation to rewind.
     */
    RewindAnimation :: proc(player: ^AnimationPlayer, animIndex: i32) ---

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
     * @brief Gets the blending weight of an animation.
     *
     * @param player Animation player.
     * @param animIndex Index of the animation.
     * @return Current weight.
     */
    GetAnimationWeight :: proc(player: AnimationPlayer, animIndex: i32) -> f32 ---

    /**
     * @brief Sets the blending weight of an animation.
     *
     * @param player Animation player.
     * @param animIndex Index of the animation.
     * @param weight Blending weight to apply.
     */
    SetAnimationWeight :: proc(player: ^AnimationPlayer, animIndex: i32, weight: f32) ---

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
     * @brief Advances the time of all active animations.
     *
     * Updates all internal animation timers based on speed and delta time.
     * Does NOT recalculate the skeleton pose.
     *
     * @param player Animation player.
     * @param dt Delta time in seconds.
     */
    AdvanceAnimationPlayerTime :: proc(player: ^AnimationPlayer, dt: f32) ---

    /**
     * @brief Calculates the current blended local pose of the skeleton.
     *
     * Interpolates keyframes and blends all active animations according to their weights,
     * but only computes the local transforms of each bone relative to its parent.
     * Does NOT advance animation time.
     *
     * @param player Animation player whose local pose will be updated.
     */
    CalculateAnimationPlayerLocalPose :: proc(player: ^AnimationPlayer) ---

    /**
     * @brief Calculates the current blended model (global) pose of the skeleton.
     *
     * Interpolates keyframes and blends all active animations according to their weights,
     * but only computes the global transforms of each bone in model space.
     * This assumes the local pose is already up-to-date.
     * Does NOT advance animation time.
     *
     * @param player Animation player whose model pose will be updated.
     */
    CalculateAnimationPlayerModelPose :: proc(player: ^AnimationPlayer) ---

    /**
     * @brief Calculates the current blended skeleton pose (local and model).
     *
     * Interpolates keyframes and blends all active animations according to their weights,
     * then computes both local and model transforms for the entire skeleton.
     * Does NOT advance animation time.
     *
     * @param player Animation player whose local and model poses will be updated.
     */
    CalculateAnimationPlayerPose :: proc(player: ^AnimationPlayer) ---

    /**
     * @brief Calculates the skinning matrices and uploads them to the GPU.
     *
     * @param player Animation player.
     */
    UploadAnimationPlayerPose :: proc(player: ^AnimationPlayer) ---

    /**
     * @brief Updates the animation player: calculates and upload blended pose, then advances time.
     *
     * Equivalent to calling R3D_CalculateAnimationPlayerPose() followed by
     * R3D_UploadAnimationPlayerPose() and R3D_AdvanceAnimationPlayerTime().
     *
     * @param player Animation player.
     * @param dt Delta time in seconds.
     */
    UpdateAnimationPlayer :: proc(player: ^AnimationPlayer, dt: f32) ---
}

