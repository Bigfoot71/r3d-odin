/* r3d_pack.odin -- R3D Pack Module.
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
        "macos/libr3d.a",
    }
}

@(default_calling_convention="c", link_prefix="R3D_")
foreign lib {
    /**
     * @brief Packs a 32-bit float into a 16-bit floating-point value.
     *
     * @param x Value to pack.
     *
     * @return IEEE 754 half-precision representation.
     */
    PackFloat16 :: proc(x: f32) -> u16 ---

    /**
     * @brief Packs a float into a 16-bit unsigned normalized value.
     *
     * The input value is clamped to the [0, 1] range before packing.
     *
     * @param x Value to pack.
     *
     * @return 16-bit UNORM representation.
     */
    PackUnorm16 :: proc(x: f32) -> u16 ---

    /**
     * @brief Packs a float into a 16-bit signed normalized value.
     *
     * The input value is clamped to the [-1, 1] range before packing.
     *
     * @param x Value to pack.
     *
     * @return 16-bit SNORM representation.
     */
    PackSnorm16 :: proc(x: f32) -> i16 ---

    /**
     * @brief Packs a float into an 8-bit unsigned normalized value.
     *
     * The input value is clamped to the [0, 1] range before packing.
     *
     * @param x Value to pack.
     *
     * @return 8-bit UNORM representation.
     */
    PackUnorm8 :: proc(x: f32) -> u8 ---

    /**
     * @brief Packs a float into an 8-bit signed normalized value.
     *
     * The input value is clamped to the [-1, 1] range before packing.
     *
     * @param x Value to pack.
     *
     * @return 8-bit SNORM representation.
     */
    PackSnorm8 :: proc(x: f32) -> i8 ---

    /**
     * @brief Unpacks a 16-bit floating-point value into a 32-bit float.
     *
     * @param x IEEE 754 half-precision representation.
     *
     * @return Unpacked float value.
     */
    UnpackFloat16 :: proc(x: u16) -> f32 ---

    /**
     * @brief Unpacks a 16-bit unsigned normalized value.
     *
     * The returned value is in the [0, 1] range.
     *
     * @param x 16-bit UNORM representation.
     *
     * @return Unpacked float value.
     */
    UnpackUnorm16 :: proc(x: u16) -> f32 ---

    /**
     * @brief Unpacks a 16-bit signed normalized value.
     *
     * The returned value is clamped to the [-1, 1] range.
     *
     * @param x 16-bit SNORM representation.
     *
     * @return Unpacked float value.
     */
    UnpackSnorm16 :: proc(x: i16) -> f32 ---

    /**
     * @brief Unpacks an 8-bit unsigned normalized value.
     *
     * The returned value is in the [0, 1] range.
     *
     * @param x 8-bit UNORM representation.
     *
     * @return Unpacked float value.
     */
    UnpackUnorm8 :: proc(x: u8) -> f32 ---

    /**
     * @brief Unpacks an 8-bit signed normalized value.
     *
     * The returned value is clamped to the [-1, 1] range.
     *
     * @param x 8-bit SNORM representation.
     *
     * @return Unpacked float value.
     */
    UnpackSnorm8 :: proc(x: i8) -> f32 ---
}

