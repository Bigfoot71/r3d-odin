/* r3d_core.odin -- R3D Core Module.
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
 * @brief Anti-aliasing modes for rendering.
 */
AntiAliasing :: enum u32 {
    DISABLED = 0, ///< Anti-aliasing is disabled. Edges may appear jagged.
    FXAA     = 1, ///< FXAA is applied. Smooths edges efficiently but may appear blurry.
}

/**
 * @brief Aspect ratio handling modes for rendering.
 */
AspectMode :: enum u32 {
    EXPAND = 0, ///< Expands the rendered output to fully fill the target (render texture or window).
    KEEP   = 1, ///< Preserves the target's aspect ratio without distortion, adding empty gaps if necessary.
}

/**
 * @brief Upscaling/filtering methods for rendering output.
 *
 * Upscale mode to apply when the output window is larger than the internal render resolution.
 */
UpscaleMode :: enum u32 {
    NEAREST = 0, ///< Nearest-neighbor upscaling: very fast, but produces blocky pixels.
    LINEAR  = 1, ///< Bilinear upscaling: very fast, smoother than nearest, but can appear blurry.
    BICUBIC = 2, ///< Bicubic (Catmull-Rom) upscaling: slower, smoother, and less blurry than linear.
    LANCZOS = 3, ///< Lanczos-2 upscaling: preserves more fine details, but is the most expensive.
}

/**
 * @brief Downscaling/filtering methods for rendering output.
 *
 * Downscale mode to apply when the output window is smaller than the internal render resolution.
 */
DownscaleMode :: enum u32 {
    NEAREST = 0, ///< Nearest-neighbor downscaling: very fast, but produces aliasing.
    LINEAR  = 1, ///< Bilinear downscaling: very fast, can serve as a basic form of anti-aliasing (SSAA).
    BOX     = 2, ///< Box-blur downscaling: uses a simple but effective box blur, slightly more expensive than linear, smooths moiré better.
}

/**
 * @brief Defines the buffer to output (render texture or window).
 * @note Nothing will be output if the requested target has not been created / used.
 */
OutputMode :: enum u32 {
    SCENE    = 0,
    ALBEDO   = 1,
    NORMAL   = 2,
    ORM      = 3,
    DIFFUSE  = 4,
    SPECULAR = 5,
    SSAO     = 6,
    SSIL     = 7,
    SSGI     = 8,
    SSR      = 9,
    BLOOM    = 10,
    DOF      = 11,
}

/**
 * @brief Specifies the color space for user-provided colors and color textures.
 *
 * This enum defines how colors are interpreted for material inputs:
 * - Surface colors (e.g., albedo or emission tint)
 * - rl.Color textures (albedo, emission maps)
 *
 * Lighting values (direct or indirect light) are always linear and
 * are not affected by this setting.
 *
 * Used with `R3D_SetColorSpace()` to control whether input colors
 * should be treated as linear or sRGB.
 */
ColorSpace :: enum u32 {
    LINEAR = 0, ///< Linear color space: values are used as-is.
    SRGB   = 1, ///< sRGB color space: values are converted to linear on load.
}

@(default_calling_convention="c", link_prefix="R3D_")
foreign lib {
    /**
     * @brief Initializes the rendering engine.
     *
     * This function sets up the internal rendering system with the provided resolution.
     *
     * @param resWidth Width of the internal resolution.
     * @param resHeight Height of the internal resolution.
     *
     * @return True if the initialization is successful.
     */
    Init :: proc(resWidth: i32, resHeight: i32) -> bool ---

    /**
     * @brief Closes the rendering engine and deallocates all resources.
     *
     * This function shuts down the rendering system and frees all allocated memory,
     * including the resources associated with the created lights.
     */
    Close :: proc() ---

    /**
     * @brief Gets the current internal resolution.
     *
     * This function retrieves the current internal resolution being used by the
     * rendering engine.
     *
     * @param width Pointer to store the width of the internal resolution.
     * @param height Pointer to store the height of the internal resolution.
     */
    GetResolution :: proc(width: ^i32, height: ^i32) ---

    /**
     * @brief Updates the internal resolution.
     *
     * This function changes the internal resolution of the rendering engine. Note that
     * this process destroys and recreates all framebuffers, which may be a slow operation.
     *
     * @param width The new width for the internal resolution.
     * @param height The new height for the internal resolution.
     *
     * @warning This function may be slow due to the destruction and recreation of framebuffers.
     */
    UpdateResolution :: proc(width: i32, height: i32) ---

    /**
     * @brief Retrieves the current anti-aliasing mode used for rendering.
     * @return The currently active R3D_AntiAliasing mode.
     */
    GetAntiAliasing :: proc() -> AntiAliasing ---

    /**
     * @brief Sets the anti-aliasing mode for rendering.
     * @param mode The desired R3D_AntiAliasing mode.
     */
    SetAntiAliasing :: proc(mode: AntiAliasing) ---

    /**
     * @brief Retrieves the current aspect ratio handling mode.
     * @return The currently active R3D_AspectMode.
     */
    GetAspectMode :: proc() -> AspectMode ---

    /**
     * @brief Sets the aspect ratio handling mode for rendering.
     * @param mode The desired R3D_AspectMode.
     */
    SetAspectMode :: proc(mode: AspectMode) ---

    /**
     * @brief Retrieves the current upscaling/filtering method.
     * @return The currently active R3D_UpscaleMode.
     */
    GetUpscaleMode :: proc() -> UpscaleMode ---

    /**
     * @brief Sets the upscaling/filtering method for rendering output.
     * @param mode The desired R3D_UpscaleMode.
     */
    SetUpscaleMode :: proc(mode: UpscaleMode) ---

    /**
     * @brief Retrieves the current downscaling mode used for rendering.
     * @return The currently active R3D_DownscaleMode.
     */
    GetDownscaleMode :: proc() -> DownscaleMode ---

    /**
     * @brief Sets the downscaling mode for rendering output.
     * @param mode The desired R3D_DownscaleMode.
     */
    SetDownscaleMode :: proc(mode: DownscaleMode) ---

    /**
     * @brief Gets the current output mode.
     * @return The currently active R3D_OutputMode.
     */
    GetOutputMode :: proc() -> OutputMode ---

    /**
     * @brief Sets the output mode for rendering.
     * @param mode The R3D_OutputMode to use.
     * @note Nothing will be output if the requested target has not been created / used.
     */
    SetOutputMode :: proc(mode: OutputMode) ---

    /**
     * @brief Sets the default texture filtering mode.
     *
     * This function defines the default texture filter that will be applied to all subsequently
     * loaded textures, including those used in materials, sprites, and other resources.
     *
     * If a trilinear or anisotropic filter is selected, mipmaps will be automatically generated
     * for the textures, but they will not be generated when using nearest or bilinear filtering.
     *
     * The default texture filter mode is `TEXTURE_FILTER_TRILINEAR`.
     *
     * @param filter The texture filtering mode to be applied by default.
     */
    SetTextureFilter :: proc(filter: rl.TextureFilter) ---

    /**
     * @brief Set the working color space for user-provided surface colors and color textures.
     *
     * Defines how all *color inputs* should be interpreted:
     * - surface colors provided in materials (e.g. albedo/emission tints)
     * - color textures such as albedo and emission maps
     *
     * When set to sRGB, these values are converted to linear before shading.
     * When set to linear, values are used as-is.
     *
     * This does NOT affect lighting inputs (direct or indirect light),
     * which are always expected to be provided in linear space.
     *
     * The default color space is `R3D_COLORSPACE_SRGB`.
     *
     * @param space rl.Color space to use for color inputs (linear or sRGB).
     */
    SetColorSpace :: proc(space: ColorSpace) ---

    /**
     * @brief Get the currently active global rendering layers.
     *
     * Returns the bitfield representing the currently active layers in the renderer.
     * By default, the internal active layers are set to 0, which means that any
     * non-zero layer assigned to an object will NOT be rendered unless explicitly
     * activated.
     *
     * @return R3D_Layer Bitfield of active layers.
     */
    GetActiveLayers :: proc() -> Layer ---

    /**
     * @brief Set the active global rendering layers.
     *
     * Replaces the current set of active layers with the given bitfield.
     *
     * @param bitfield Bitfield representing the layers to activate.
     */
    SetActiveLayers :: proc(bitfield: Layer) ---

    /**
     * @brief Enable one or more layers without affecting other active layers.
     *
     * This function sets the bits in the global active layers corresponding to
     * the bits in the provided bitfield. Layers already active remain active.
     *
     * @param bitfield Bitfield representing one or more layers to enable.
     */
    EnableLayers :: proc(bitfield: Layer) ---

    /**
     * @brief Disable one or more layers without affecting other active layers.
     *
     * This function clears the bits in the global active layers corresponding to
     * the bits in the provided bitfield. Layers not included in the bitfield
     * remain unchanged.
     *
     * @param bitfield Bitfield representing one or more layers to disable.
     */
    DisableLayers :: proc(bitfield: Layer) ---
}

/**
 * @brief Bitfield type used to specify rendering layers for 3D objects.
 *
 * This type is used by `R3D_Mesh` and `R3D_Sprite` objects to indicate
 * which rendering layer(s) they belong to. Active layers are controlled
 * globally via the functions:
 * 
 * - void R3D_EnableLayers(R3D_Layer bitfield);
 * - void R3D_DisableLayers(R3D_Layer bitfield);
 *
 * A mesh or sprite will be rendered if at least one of its assigned layers is active.
 *
 * For simplicity, 16 layers are defined in this header, but the maximum number
 * of layers is 32 for an uint32_t.
 */
Layer :: enum u32 {
    LAYER_01 = 1 << 0,
    LAYER_02 = 1 << 1,
    LAYER_03 = 1 << 2,
    LAYER_04 = 1 << 3,
    LAYER_05 = 1 << 4,
    LAYER_06 = 1 << 5,
    LAYER_07 = 1 << 6,
    LAYER_08 = 1 << 7,
    LAYER_09 = 1 << 8,
    LAYER_10 = 1 << 9,
    LAYER_11 = 1 << 10,
    LAYER_12 = 1 << 11,
    LAYER_13 = 1 << 12,
    LAYER_14 = 1 << 13,
    LAYER_15 = 1 << 14,
    LAYER_16 = 1 << 15,
    LAYER_ALL = 0xFFFFFFFF,
}
