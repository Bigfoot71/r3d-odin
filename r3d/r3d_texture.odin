/* r3d_texture.odin -- R3D rl.Texture Module.
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
     * @brief Loads a texture from the specified file path.
     *
     * If 'isColor' is true, the texture is loaded using the currently defined color space (sRGB by default).
     * The wrap and filter modes are taken from the current global default state.
     *
     * @param fileName The path to the texture file.
     * @param isColor Whether the texture should be treated as color data.
     * @return The loaded texture.
     */
    LoadTexture :: proc(fileName: cstring, isColor: bool) -> rl.Texture2D ---

    /**
     * @brief Loads a texture from the specified file path.
     *
     * If 'isColor' is true, the texture is loaded using the currently defined color space (sRGB by default).
     *
     * @param fileName The path to the texture file.
     * @param wrap The texture wrap mode.
     * @param filter The texture filter mode.
     * @param isColor Whether the texture should be treated as color data.
     * @return The loaded texture.
     */
    LoadTextureEx :: proc(fileName: cstring, wrap: rl.TextureWrap, filter: rl.TextureFilter, isColor: bool) -> rl.Texture2D ---

    /**
     * @brief Loads a texture from the specified image.
     *
     * If 'isColor' is true, the texture is loaded using the currently defined color space (sRGB by default).
     * The wrap and filter modes are taken from the current global default state.
     *
     * @param image The source image.
     * @param isColor Whether the texture should be treated as color data.
     * @return The loaded texture.
     */
    LoadTextureFromImage :: proc(image: rl.Image, isColor: bool) -> rl.Texture2D ---

    /**
     * @brief Loads a texture from the specified image.
     *
     * If 'isColor' is true, the texture is loaded using the currently defined color space (sRGB by default).
     *
     * @param image The source image.
     * @param wrap The texture wrap mode.
     * @param filter The texture filter mode.
     * @param isColor Whether the texture should be treated as color data.
     * @return The loaded texture.
     */
    LoadTextureFromImageEx :: proc(image: rl.Image, wrap: rl.TextureWrap, filter: rl.TextureFilter, isColor: bool) -> rl.Texture2D ---

    /**
     * @brief Loads a texture directly from memory.
     *
     * If 'isColor' is true, the texture is loaded using the currently defined color space (sRGB by default).
     * The wrap and filter modes are taken from the current global default state.
     *
     * @param fileType The file type/extension used to interpret the data.
     * @param fileData A pointer to the file data in memory.
     * @param dataSize The size of the file data in bytes.
     * @param isColor Whether the texture should be treated as color data.
     * @return The loaded texture.
     */
    LoadTextureFromMemory :: proc(fileType: cstring, fileData: rawptr, dataSize: i32, isColor: bool) -> rl.Texture2D ---

    /**
     * @brief Loads a texture directly from memory.
     *
     * If 'isColor' is true, the texture is loaded using the currently defined color space (sRGB by default).
     *
     * @param fileType The file type/extension used to interpret the data.
     * @param fileData A pointer to the file data in memory.
     * @param dataSize The size of the file data in bytes.
     * @param wrap The texture wrap mode.
     * @param filter The texture filter mode.
     * @param isColor Whether the texture should be treated as color data.
     * @return The loaded texture.
     */
    LoadTextureFromMemoryEx :: proc(fileType: cstring, fileData: rawptr, dataSize: i32, wrap: rl.TextureWrap, filter: rl.TextureFilter, isColor: bool) -> rl.Texture2D ---

    /**
     * @brief Unloads a texture.
     *
     * This function calls raylib's `UnloadTexture` internally, while ensuring that
     * the provided texture is not an internal r3d texture.
     *
     * @param texture The texture to unload.
     */
    UnloadTexture :: proc(texture: rl.Texture2D) ---
}

