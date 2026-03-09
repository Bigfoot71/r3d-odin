/* r3d_color.odin -- R3D rl.Color Module.
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

@(default_calling_convention="c", link_prefix="R3D_")
foreign lib {
    /**
     * @brief Converts an sRGB color to linear space.
     *
     * @param color The sRGB color to convert.
     * @return The converted linear color as a rl.Vector4.
     */
    ColorSrgbToLinear :: proc(color: rl.Color) -> rl.Vector4 ---

    /**
     * @brief Converts an sRGB color to linear space.
     *
     * @param color The sRGB color to convert.
     * @return The converted linear color as a rl.Vector3.
     */
    ColorSrgbToLinearVector3 :: proc(color: rl.Color) -> rl.Vector3 ---

    /**
     * @brief Converts a linear color to sRGB space.
     *
     * @param color The linear color to convert.
     * @return The converted sRGB color.
     */
    ColorLinearToSrgb :: proc(color: rl.Vector4) -> rl.Color ---

    /**
     * @brief Converts a color from the current color space to linear space.
     *
     * @param color The color to convert.
     * @return The converted linear color as a rl.Vector4.
     */
    ColorFromCurrentSpace :: proc(color: rl.Color) -> rl.Vector4 ---

    /**
     * @brief Converts a color from the current color space to linear space.
     *
     * @param color The color to convert.
     * @return The converted linear color as a rl.Vector3.
     */
    ColorFromCurrentSpaceVector3 :: proc(color: rl.Color) -> rl.Vector3 ---
}

