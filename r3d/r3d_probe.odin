/* r3d_probe.odin -- R3D Probe Module.
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

// ========================================
// ENUM TYPES
// ========================================
ProbeType :: enum u32 {
    ILLUMINATION = 0,
    REFLECTION   = 1,
}

// ========================================
// STRUCT TYPES
// ========================================
Probe :: struct {
    type:     ProbeType,
    handle:   u32, ///< Internal probe handle (don't touch)
    position: rl.Vector3,
    falloff:  f32,
    range:    f32,
    interior: bool,
    shadows:  bool,
}

@(default_calling_convention="c", link_prefix="R3D_")
foreign lib {
    /**
     * @brief Allocates a probe of the given type.
     *
     * @param type Whether this probe contributes indirect lighting or reflections.
     * @param interior Whether the skybox is taken into account when capturing this probe.
     * @param shadow Whether shadow casters are taken into account when capturing this probe.
     */
    LoadProbe :: proc(type: ProbeType, interior: bool, shadow: bool) -> Probe ---

    /**
     * @brief Releases a probe, freeing its layer for reuse.
     */
    UnloadProbe :: proc(probe: Probe) ---

    /**
     * @brief Returns whether the probe has a valid allocated layer.
     */
    IsProbeValid :: proc(probe: Probe) -> bool ---
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
