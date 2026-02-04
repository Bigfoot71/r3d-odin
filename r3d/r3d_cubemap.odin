/* r3d_cubemap.odin -- R3D Cubemap Module.
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
 * @brief Supported cubemap source layouts.
 *
 * Used when converting an image into a cubemap. AUTO_DETECT tries to guess
 * the layout based on image dimensions.
 */
CubemapLayout :: enum u32 {
    AUTO_DETECT         = 0, ///< Automatically detect layout type
    LINE_VERTICAL       = 1, ///< Layout is defined by a vertical line with faces
    LINE_HORIZONTAL     = 2, ///< Layout is defined by a horizontal line with faces
    CROSS_THREE_BY_FOUR = 3, ///< Layout is defined by a 3x4 cross with cubemap faces
    CROSS_FOUR_BY_THREE = 4, ///< Layout is defined by a 4x3 cross with cubemap faces
    PANORAMA            = 5, ///< Layout is defined by an equirectangular panorama
}

/**
 * @brief GPU cubemap texture.
 *
 * Holds the OpenGL texture handle and its base resolution (per face).
 */
Cubemap :: struct {
    texture: u32,
    fbo:     u32,
    size:    i32,
}

/**
 * @brief Parameters for procedural sky generation.
 *
 * Curves control gradient falloff (lower = sharper transition at horizon).
 */
CubemapSky :: struct {
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
     * @brief Loads a cubemap from an image file.
     *
     * The layout parameter tells how faces are arranged inside the source image.
     */
    LoadCubemap :: proc(fileName: cstring, layout: CubemapLayout) -> Cubemap ---

    /**
     * @brief Builds a cubemap from an existing rl.Image.
     *
     * Same behavior as R3D_LoadCubemap(), but without loading from disk.
     */
    LoadCubemapFromImage :: proc(image: rl.Image, layout: CubemapLayout) -> Cubemap ---

    /**
     * @brief Generates a procedural sky cubemap.
     *
     * Creates a GPU cubemap with procedural gradient sky and sun rendering.
     * The cubemap is ready for use as environment map or IBL source.
     */
    GenCubemapSky :: proc(size: i32, params: CubemapSky) -> Cubemap ---

    /**
     * @brief Releases GPU resources associated with a cubemap.
     */
    UnloadCubemap :: proc(cubemap: Cubemap) ---

    /**
     * @brief Updates an existing procedural sky cubemap.
     *
     * Re-renders the cubemap with new parameters. Faster than unload + generate
     * when animating sky conditions (time of day, weather, etc.).
     */
    UpdateCubemapSky :: proc(cubemap: ^Cubemap, params: CubemapSky) ---
}

CUBEMAP_SKY_BASE :: CubemapSky {
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
