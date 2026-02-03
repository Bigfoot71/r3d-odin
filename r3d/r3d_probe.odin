/* r3d_probe.odin -- R3D Probe Module.
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
 * @brief Modes for updating probes.
 *
 * Controls how often probe captures are refreshed.
 */
ProbeUpdateMode :: enum u32 {
    ONCE   = 0, ///< Updated only when its state or content changes
    ALWAYS = 1, ///< Updated during every frames
}

/**
 * @brief Unique identifier for an R3D probe.
 *
 * Negative values indicate an invalid probe.
 */
Probe :: i32

@(default_calling_convention="c", link_prefix="R3D_")
foreign lib {
    /**
     * @brief Creates a new probe of the specified type.
     *
     * The returned probe must be destroyed using ::R3D_DestroyProbe
     * when it is no longer needed.
     *
     * @param flags IBL components that the probe must support.
     * @return A valid probe ID, or a negative value on failure.
     */
    CreateProbe :: proc(flags: ProbeFlags) -> Probe ---

    /**
     * @brief Destroys a probe and frees its resources.
     *
     * @param id Probe ID to destroy.
     */
    DestroyProbe :: proc(id: Probe) ---

    /**
     * @brief Returns whether a probe exists.
     *
     * @param id Probe ID.
     * @return true if the probe is valid and allocated, otherwise false.
     */
    IsProbeExist :: proc(id: Probe) -> bool ---

    /**
     * @brief Returns the probe flags.
     *
     * @param id Probe ID.
     * @return The flags assigned to the probe.
     */
    GetProbeFlags :: proc(id: Probe) -> ProbeFlags ---

    /**
     * @brief Returns whether a probe is currently active.
     *
     * Inactive probes do not contribute to lighting.
     *
     * @param id Probe ID.
     * @return true if active, otherwise false.
     */
    IsProbeActive :: proc(id: Probe) -> bool ---

    /**
     * @brief Enables or disables a probe.
     *
     * @param id Probe ID.
     * @param active Set to true to enable the probe.
     */
    SetProbeActive :: proc(id: Probe, active: bool) ---

    /**
     * @brief Gets the probe update mode.
     *
     * - R3D_PROBE_UPDATE_ONCE:
     *     Captured once, then reused unless its state changes.
     *
     * - R3D_PROBE_UPDATE_ALWAYS:
     *     Recaptured every frame.
     *
     * Use "ONCE" for static scenes, "ALWAYS" for highly dynamic scenes.
     */
    GetProbeUpdateMode :: proc(id: Probe) -> ProbeUpdateMode ---

    /**
     * @brief Sets the probe update mode.
     *
     * Controls when the probe capture is refreshed.
     *
     * @param id Probe ID.
     * @param mode Update mode to apply.
     */
    SetProbeUpdateMode :: proc(id: Probe, mode: ProbeUpdateMode) ---

    /**
     * @brief Returns whether the probe is considered indoors.
     *
     * Indoor probes do not sample skybox or environment maps.
     * Instead they rely only on ambient and background colors.
     *
     * Use this for rooms, caves, tunnels, etc...
     * where outside lighting should not bleed inside.
     */
    GetProbeInterior :: proc(id: Probe) -> bool ---

    /**
     * @brief Enables or disables indoor mode for the probe.
     */
    SetProbeInterior :: proc(id: Probe, active: bool) ---

    /**
     * @brief Returns whether shadows are captured by this probe.
     *
     * When enabled, shadowing is baked into the captured lighting.
     * This improves realism, but increases capture cost.
     */
    GetProbeShadows :: proc(id: Probe) -> bool ---

    /**
     * @brief Enables or disables shadow rendering during probe capture.
     */
    SetProbeShadows :: proc(id: Probe, active: bool) ---

    /**
     * @brief Gets the world position of the probe.
     */
    GetProbePosition :: proc(id: Probe) -> rl.Vector3 ---

    /**
     * @brief Sets the world position of the probe.
     */
    SetProbePosition :: proc(id: Probe, position: rl.Vector3) ---

    /**
     * @brief Gets the effective range of the probe.
     *
     * The range defines the radius (in world units) within which this probe
     * contributes to lighting. Objects outside this sphere receive no influence.
     */
    GetProbeRange :: proc(id: Probe) -> f32 ---

    /**
     * @brief Sets the effective range of the probe.
     *
     * @param range Radius in world units. Must be > 0.
     */
    SetProbeRange :: proc(id: Probe, range: f32) ---

    /**
     * @brief Gets the falloff factor applied to probe contributions.
     *
     * Falloff controls how lighting fades as distance increases.
     *
     * Internally this uses a power curve:
     *     attenuation = 1.0 - pow(dist / probe.range, probe.falloff)
     *
     * Effects:
     *   - falloff = 1 -> linear fade
     *   - falloff > 1 -> light stays strong near the probe, drops faster at the edge
     *   - falloff < 1 -> softer fade across the whole range
     */
    GetProbeFalloff :: proc(id: Probe) -> f32 ---

    /**
     * @brief Sets the falloff factor used for distance attenuation.
     *
     * Larger values make the probe feel more localized.
     */
    SetProbeFalloff :: proc(id: Probe, falloff: f32) ---
}

/**
 * @brief Bit-flags controlling what components are generated.
 *
 * - R3D_PROBE_ILLUMINATION -> generate diffuse irradiance
 * - R3D_PROBE_REFLECTION   -> generate specular prefiltered map
 */
ProbeFlag :: enum u32 {
    ILLUMINATION = 0,
    REFLECTION   = 1,
}

ProbeFlags :: bit_set[ProbeFlag; u32]
