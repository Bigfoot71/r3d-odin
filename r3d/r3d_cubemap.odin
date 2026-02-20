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
     * @brief Releases GPU resources associated with a cubemap.
     */
    UnloadCubemap :: proc(cubemap: Cubemap) ---
}

