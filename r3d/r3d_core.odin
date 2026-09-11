/* r3d_core.odin -- R3D Core Module.
 *
 * Copyright (c) 2025-2026 Le Juez Victor
 *
 * This software is provided 'as-is', without any express or implied warranty.
 * For conditions of distribution and use, see accompanying LICENSE file.
 */
package r3d

import rl "vendor:raylib"

/**
 * @brief Configuration hints used to customize R3D before initialization.
 *
 * Hints must be set via @ref R3D_SetHint() before calling @ref R3D_Init().
 * Any hint not explicitly set falls back to its default value.
 *
 * @note Some hints may be clamped internally, accordingly to hardware limits.
 */
Hint :: enum u32 {
    MESH_VERTEX_BUFFER_CAPACITY   = 0,  ///< Initial vertex capacity of the global VBO. Default: 65'536
    MESH_INDEX_BUFFER_CAPACITY    = 1,  ///< Initial index capacity of the global EBO. Default: 131'072
    MESH_STREAMING_CAPACITY       = 2,  ///< Initial capacity for tracking freed mesh slots, relevant only for meshes loaded/unloaded at runtime. Default: 128
    DRAW_CALL_CAPACITY            = 3,  ///< Initial capacity of the CPU-side draw call list. Default: 1024
    FORWARD_LIGHT_PER_MESH        = 4,  ///< Max lights per mesh in forward pass. Default: 16
    PROBE_ILLUMINATION_MAX_ACTIVE = 5,  ///< Max illumination probes rendered simultaneously. Default: 32
    PROBE_REFLECTION_MAX_ACTIVE   = 6,  ///< Max reflection probes rendered simultaneously. Default: 8
    SHADOW_DIR_SIZE               = 7,  ///< Directional light shadow map size (px). Default: 4096
    SHADOW_SPOT_SIZE              = 8,  ///< Spot light shadow map size (px). Default: 2048
    SHADOW_OMNI_SIZE              = 9,  ///< Omni light shadow map size (px). Default: 2048
    IBL_IRRADIANCE_SIZE           = 10, ///< Irradiance cubemap face size, shared by ambient IBL and probes (px). Default: 32
    IBL_PREFILTER_SIZE            = 11, ///< Prefiltered cubemap face size, shared by ambient IBL and probes (px). Default: 128
    COUNT                         = 12, ///< Sentinel, not a valid hint
}

/**
 * @brief Anti-aliasing modes used during rendering.
 *
 * Anti-aliasing reduces visible jagged edges (aliasing artifacts)
 * in the final rendered image.
 */
AntiAliasingMode :: enum u32 {
    NONE = 0, ///< No anti-aliasing. Best performance, visible jagged edges.
    FXAA = 1, ///< Fast Approximate AA. Smooths edges efficiently but may appear blurry.
    SMAA = 2, ///< Subpixel Morphological AA. Sharper than FXAA, moderate performance cost.
}

/**
 * @brief Quality presets for anti-aliasing.
 *
 * Presets adjust internal algorithm parameters (e.g. edge detection,
 * search steps, thresholds). Higher presets increase quality and GPU cost.
 */
AntiAliasingPreset :: enum u32 {
    LOW    = 0, ///< Performance-oriented preset with reduced quality.
    MEDIUM = 1, ///< Balanced quality/performance preset.
    HIGH   = 2, ///< High quality preset with increased GPU cost.
    ULTRA  = 3, ///< Maximum quality preset, highest performance cost.
    COUNT  = 4, ///< Number of presets (not a valid preset value).
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
    BICUBIC = 2, ///< Bicubic upscaling: slower, smoother, and less blurry than linear.
    LANCZOS = 3, ///< Lanczos-2 upscaling: preserves more fine details, but is the most expensive.
}

/**
 * @brief Downscaling/filtering methods for rendering output.
 *
 * Downscale mode to apply when the output window is smaller than the internal render resolution.
 */
DownscaleMode :: enum u32 {
    NEAREST = 0, ///< Nearest-neighbor downscaling: very fast, but produces aliasing.
    LINEAR  = 1, ///< Bilinear filtering. Fast, may show moire on high-frequency content.
    RGSS    = 2, ///< 4-sample supersampling. Reduces aliasing and moire, low cost. Recommended default.
    PDSS    = 3, ///< 16-sample supersampling. Better color accuracy than RGSS, higher cost.
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
    RADIANCE = 4,
    SPECULAR = 5,
    SSAO     = 6,
    SSIL     = 7,
    SSGI     = 8,
    SSR      = 9,
    BLOOM    = 10,
    DOF      = 11,
}

@(default_calling_convention="c", link_prefix="R3D_")
foreign lib {
    /**
     * @brief Sets a configuration hint.
     *
     * Must be called before @ref R3D_Init().
     */
    SetHint :: proc(hint: Hint, value: i32) ---

    /**
     * @brief Returns the effective value of a hint.
     */
    GetHint :: proc(hint: Hint) -> i32 ---

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
     * @brief Sets the internal rendering resolution.
     *
     * Reallocates all internal render targets to the new resolution.
     * This operation may cause a stall, this is acceptable when called
     * infrequently (like window resize events), but should never be called per-frame.
     *
     * @param width New internal width in pixels.
     * @param height New internal height in pixels.
     */
    SetResolution :: proc(width: i32, height: i32) ---

    /**
     * @brief Retrieves the current anti-aliasing mode used for rendering.
     *
     * @return The currently active R3D_AntiAliasingMode.
     */
    GetAntiAliasingMode :: proc() -> AntiAliasingMode ---

    /**
     * @brief Sets the anti-aliasing mode for rendering.
     *
     * The new mode takes effect on subsequent frames.
     *
     * @param mode The desired R3D_AntiAliasingMode.
     * @note If the mode is invalid, no AA will be applied.
     */
    SetAntiAliasingMode :: proc(mode: AntiAliasingMode) ---

    /**
     * @brief Retrieves the current anti-aliasing quality preset.
     *
     * @return The currently active R3D_AntiAliasingPreset.
     */
    GetAntiAliasingPreset :: proc() -> AntiAliasingPreset ---

    /**
     * @brief Sets the anti-aliasing quality preset.
     *
     * Changing the preset triggers an internal shader recompilation.
     * Compiled variants are cached and reused if the preset is set again.
     *
     * @param preset The desired R3D_AntiAliasingPreset.
     * @note The preset will be a clamp between low and ultra.
     */
    SetAntiAliasingPreset :: proc(preset: AntiAliasingPreset) ---

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
     * @brief Sets the default texture wrap mode.
     *
     * This function only affects textures that are loaded manually for material maps.
     * Textures loaded automatically during model import will use the wrap mode
     * defined in the model file itself.
     *
     * The default texture wrap mode is `TEXTURE_WRAP_CLAMP`.
     *
     * @param wrap The texture wrap mode to apply by default.
     */
    SetTextureWrap :: proc(wrap: rl.TextureWrap) ---
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

/*
 * NOTE: Full dependency libraries are declared here rather than in all files (import.odin).
 * The exact cause is unclear, possibly an Odin linker integration issue, but having
 * all transitive deps (raylib, assimp, system libs) declared in a file that is guaranteed
 * to have referenced symbols avoids a cascade of undefined references at link time.
 * To be revisited if a minimal reproducer can be found and reported to Odin.
 */
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
        "macos/libr3d.a",
        "vendor:raylib/macos/libraylib.a",
        "macos/libassimp.a",
        "system:z",
        "system:c++",
    }
}
