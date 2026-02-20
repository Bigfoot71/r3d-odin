/* r3d_sky.odin -- R3D Sky Module.
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
 * @brief Parameters for procedural sky generation.
 *
 * Curves control gradient falloff (lower = sharper transition at horizon).
 */
ProceduralSky :: struct {
    skyTopColor:        rl.Color,   // Sky color at zenith
    skyHorizonColor:    rl.Color,   // Sky color at horizon
    skyHorizonCurve:    f32,     // Gradient curve exponent (0.01 - 1.0, typical: 0.15)
    skyEnergy:          f32,     // Sky brightness multiplier
    groundBottomColor:  rl.Color,   // Ground color at nadir
    groundHorizonColor: rl.Color,   // Ground color at horizon
    groundHorizonCurve: f32,     // Gradient curve exponent (typical: 0.02)
    groundEnergy:       f32,     // Ground brightness multiplier
    sunDirection:       rl.Vector3, // Direction from which light comes (can take not normalized)
    sunColor:           rl.Color,   // Sun disk color
    sunSize:            f32,     // Sun angular size in radians (real sun: ~0.0087 rad = 0.5°)
    sunCurve:           f32,     // Sun edge softness exponent (typical: 0.15)
    sunEnergy:          f32,     // Sun brightness multiplier
}

@(default_calling_convention="c", link_prefix="R3D_")
foreign lib {
    /**
     * @brief Generates a procedural sky cubemap.
     *
     * Creates a GPU cubemap with procedural gradient sky and sun rendering.
     * The cubemap is ready for use as environment map or IBL source.
     */
    GenProceduralSky :: proc(size: i32, params: ProceduralSky) -> Cubemap ---

    /**
     * @brief Generates a custom sky cubemap.
     *
     * Creates a GPU cubemap rendered using the provided sky shader.
     * The cubemap is ready for use as environment map or IBL source.
     */
    GenCustomSky :: proc(size: i32, shader: ^SkyShader) -> Cubemap ---

    /**
     * @brief Updates an existing procedural sky cubemap.
     *
     * Re-renders the cubemap with new parameters. Faster than unload + generate
     * when animating sky conditions (time of day, weather, etc.).
     */
    UpdateProceduralSky :: proc(cubemap: ^Cubemap, params: ProceduralSky) ---

    /**
     * @brief Updates an existing custom sky cubemap.
     *
     * Re-renders the cubemap using the provided sky shader. Faster than unload + generate
     * when animating sky conditions or updating shader uniforms (time, clouds, stars, etc.).
     */
    UpdateCustomSky :: proc(cubemap: ^Cubemap, shader: ^SkyShader) ---
}

PROCEDURAL_SKY_BASE :: ProceduralSky {
    skyTopColor = {98, 116, 140, 255},
    skyHorizonColor = {165, 167, 171, 255},
    skyHorizonCurve = 0.15,
    skyEnergy = 1.0,
    groundBottomColor = {51, 43, 34, 255},
    groundHorizonColor = {165, 167, 171, 255},
    groundHorizonCurve = 0.02,
    groundEnergy = 1.0,
    sunDirection = {-1.0, -1.0, -1.0},
    sunColor = {255, 255, 255, 255},
    sunSize = 1.5 * rl.DEG2RAD,
    sunCurve = 0.15,
    sunEnergy = 1.0,
}
