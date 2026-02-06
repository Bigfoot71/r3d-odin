/* r3d_environment.odin -- R3D Environment Module.
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
 * @brief Bloom effect modes.
 *
 * Different blending methods for the bloom glow effect.
 */
Bloom :: enum u32 {
    DISABLED = 0, ///< No bloom effect applied
    MIX      = 1, ///< Linear interpolation blend between scene and bloom
    ADDITIVE = 2, ///< Additive blending, intensifying bright regions
    SCREEN   = 3, ///< Screen blending for softer highlight enhancement
}

/**
 * @brief Fog effect modes.
 *
 * Distance-based fog density distribution methods.
 */
Fog :: enum u32 {
    DISABLED = 0, ///< No fog effect
    LINEAR   = 1, ///< Linear density increase between start and end distances
    EXP2     = 2, ///< Exponential squared density (exp2), more realistic
    EXP      = 3, ///< Simple exponential density increase
}

/**
 * @brief Depth of field modes.
 */
DoF :: enum u32 {
    DISABLED = 0, ///< No depth of field effect
    ENABLED  = 1, ///< Depth of field enabled with focus point and blur
}

/**
 * @brief Tone mapping algorithms.
 *
 * HDR to LDR color compression methods.
 */
Tonemap :: enum u32 {
    LINEAR   = 0, ///< Direct linear mapping (no compression)
    REINHARD = 1, ///< Reinhard operator, balanced HDR compression
    FILMIC   = 2, ///< Film-like response curve
    ACES     = 3, ///< Academy rl.Color Encoding System (cinematic standard)
    AGX      = 4, ///< Modern algorithm preserving highlights and shadows
    COUNT    = 5, ///< Internal: number of tonemap modes
}

/**
 * @brief Background and skybox configuration.
 */
EnvBackground :: struct {
    color:    rl.Color,      ///< Background color when there is no skybox
    energy:   f32,        ///< Energy multiplier applied to background (skybox or color)
    skyBlur:  f32,        ///< Sky blur factor [0,1], based on mipmaps, very fast
    sky:      Cubemap,    ///< Skybox asset (used if ID is non-zero)
    rotation: rl.Quaternion, ///< Skybox rotation (pitch, yaw, roll as quaternion)
}

/**
 * @brief Ambient lighting configuration.
 */
EnvAmbient :: struct {
    color:  rl.Color,      ///< Ambient light color when there is no ambient map
    energy: f32,        ///< Energy multiplier for ambient light (map or color)
    _map:   AmbientMap, ///< IBL environment map, can be generated from skybox
}

/**
 * @brief Screen Space Ambient Occlusion (SSAO) settings.
 *
 * Darkens areas where surfaces are close together, such as corners and crevices.
 */
EnvSSAO :: struct {
    sampleCount: i32,  ///< Number of samples to compute SSAO (default: 16)
    intensity:   f32,  ///< Base occlusion strength multiplier (default: 1.0)
    power:       f32,  ///< Exponential falloff for sharper darkening (default: 1.5)
    radius:      f32,  ///< Sampling radius in world space (default: 0.25)
    bias:        f32,  ///< Depth bias to prevent self-shadowing, good value is ~2% of the radius (default: 0.007)
    enabled:     bool, ///< Enable/disable SSAO effect (default: false)
}

/**
 * @brief Screen Space Indirect Lighting (SSIL) settings.
 *
 * Approximates indirect lighting by gathering light from nearby surfaces in screen space.
 */
EnvSSIL :: struct {
    sampleCount:  i32,  ///< Number of samples to compute indirect lighting (default: 4)
    sliceCount:   i32,  ///< Number of depth slices for accumulation (default: 4)
    sampleRadius: f32,  ///< Maximum distance to gather light from (default: 5.0)
    hitThickness: f32,  ///< Thickness threshold for occluders (default: 0.5)
    aoPower:      f32,  ///< Exponential falloff for visibility factor (too high = more noise) (default: 1.0)
    energy:       f32,  ///< Multiplier for indirect light intensity (default: 1.0)
    bounce:       f32,  /**< Bounce feeback factor. (default: 0.5)
                              *  Simulates light bounces by re-injecting the SSIL from the previous frame into the current direct light.
                              *  Be careful not to make the factor too high in order to avoid a feedback loop.
                              */
    convergence:  f32,  /**< Temporal convergence factor (0 disables it, default 0.5).
                              *  Smooths sudden light flashes by blending with previous frames.
                              *  Higher values produce smoother results but may cause ghosting.
                              *  Tip: The faster the screen changes, the higher the convergence can be acceptable.
                              *  Requires an additional history buffer (so require more memory). 
                              *  If multiple SSIL passes are done in the same frame, the history may be inconsistent, 
                              *  in that case, enable SSIL/convergence for only one pass per frame.
                              */
    enabled:      bool, ///< Enable/disable SSIL effect (default: false)
}

/**
 * @brief Screen Space Reflections (SSR) settings.
 *
 * Real-time reflections calculated in screen space.
 */
EnvSSR :: struct {
    maxRaySteps: i32,  ///< Maximum ray marching steps (default: 32)
    binarySteps: i32,  ///< Binary search refinement steps (default: 4)
    stepSize:    f32,  ///< rl.Ray step size (default: 0.125)
    thickness:   f32,  ///< Depth tolerance for valid hits (default: 0.2)
    maxDistance: f32,  ///< Maximum ray distance (default: 4.0)
    edgeFade:    f32,  ///< Screen edge fade start [0,1] (default: 0.25)
    enabled:     bool, ///< Enable/disable SSR (default: false)
}

/**
 * @brief Bloom post-processing settings.
 *
 * Glow effect around bright areas in the scene.
 */
EnvBloom :: struct {
    mode:          Bloom, ///< Bloom blending mode (default: R3D_BLOOM_DISABLED)
    levels:        f32,   ///< Mipmap spread factor [0-1]: higher = wider glow (default: 0.5)
    intensity:     f32,   ///< Bloom strength multiplier (default: 0.05)
    threshold:     f32,   ///< Minimum brightness to trigger bloom (default: 0.0)
    softThreshold: f32,   ///< Softness of brightness cutoff transition (default: 0.5)
    filterRadius:  f32,   ///< Blur filter radius during upscaling (default: 1.0)
}

/**
 * @brief Fog atmospheric effect settings.
 */
EnvFog :: struct {
    mode:      Fog,   ///< Fog distribution mode (default: R3D_FOG_DISABLED)
    color:     rl.Color, ///< Fog tint color (default: white)
    start:     f32,   ///< Linear mode: distance where fog begins (default: 1.0)
    end:       f32,   ///< Linear mode: distance of full fog density (default: 50.0)
    density:   f32,   ///< Exponential modes: fog thickness factor (default: 0.05)
    skyAffect: f32,   ///< Fog influence on skybox [0-1] (default: 0.5)
}

/**
 * @brief Depth of Field (DoF) camera focus settings.
 *
 * Blurs objects outside the focal plane.
 */
EnvDoF :: struct {
    mode:        DoF,  ///< Enable/disable state (default: R3D_DOF_DISABLED)
    focusPoint:  f32,  ///< Focus distance in meters from camera (default: 10.0)
    focusScale:  f32,  ///< Depth of field depth: lower = shallower (default: 1.0)
    maxBlurSize: f32,  ///< Maximum blur radius, similar to aperture (default: 20.0)
    debugMode:   bool, ///< rl.Color-coded visualization: green=near, blue=far (default: false)
}

/**
 * @brief Tone mapping and exposure settings.
 *
 * Converts HDR colors to displayable LDR range.
 */
EnvTonemap :: struct {
    mode:     Tonemap, ///< Tone mapping algorithm (default: R3D_TONEMAP_LINEAR)
    exposure: f32,     ///< Scene brightness multiplier (default: 1.0)
    white:    f32,     ///< Reference white point (not used for AGX) (default: 1.0)
}

/**
 * @brief rl.Color grading adjustments.
 *
 * Final color correction applied after all other effects.
 */
EnvColor :: struct {
    brightness: f32, ///< Overall brightness multiplier (default: 1.0)
    contrast:   f32, ///< Contrast between dark and bright areas (default: 1.0)
    saturation: f32, ///< rl.Color intensity (default: 1.0)
}

/**
 * @brief Complete environment configuration structure.
 *
 * Contains all rendering environment parameters: background, lighting, and post-processing effects.
 * Initialize with R3D_ENVIRONMENT_BASE for default values.
 */
Environment :: struct {
    background: EnvBackground, ///< Background and skybox settings
    ambient:    EnvAmbient,    ///< Ambient lighting configuration
    ssao:       EnvSSAO,       ///< Screen space ambient occlusion
    ssil:       EnvSSIL,       ///< Screen space indirect lighting
    ssr:        EnvSSR,        ///< Screen space reflections
    bloom:      EnvBloom,      ///< Bloom glow effect
    fog:        EnvFog,        ///< Atmospheric fog
    dof:        EnvDoF,        ///< Depth of field focus effect
    tonemap:    EnvTonemap,    ///< HDR tone mapping
    color:      EnvColor,      ///< rl.Color grading adjustments
}

@(default_calling_convention="c", link_prefix="R3D_")
foreign lib {
    /**
     * @brief Retrieves a pointer to the current environment configuration.
     *
     * Provides direct read/write access to environment settings.
     * Modifications take effect immediately.
     *
     * @return Pointer to the active R3D_Environment structure
     */
    GetEnvironment :: proc() -> ^Environment ---

    /**
     * @brief Replaces the entire environment configuration.
     *
     * Copies all settings from the provided structure to the active environment.
     * Useful for switching between presets or restoring saved states.
     *
     * @param env Pointer to the R3D_Environment structure to copy from
     */
    SetEnvironment :: proc(env: ^Environment) ---
}

/**
 * @brief Default environment configuration.
 *
 * Initializes an R3D_Environment structure with sensible default values for all
 * rendering parameters. Use this as a starting point for custom configurations.
 */
ENVIRONMENT_BASE :: Environment {
    background = {
        color    = rl.GRAY,
        energy   = 1.0,
        skyBlur  = 0.0,
        sky      = {},
        rotation = quaternion(x=0.0, y=0.0, z=0.0, w=1.0),
    },
    ambient = {
        color  = rl.BLACK,
        energy = 1.0,
        _map   = {},
    },
    ssao = {
        sampleCount = 16,
        intensity   = 1.0,
        power       = 1.5,
        radius      = 0.35,
        bias        = 0.007,
        enabled     = false,
    },
    ssil = {
        sampleCount  = 4,
        sliceCount   = 4,
        sampleRadius = 2.0,
        hitThickness = 0.5,
        aoPower      = 1.0,
        energy       = 1.0,
        bounce       = 0.5,
        convergence  = 0.5,
        enabled      = false,
    },
    ssr = {
        maxRaySteps = 32,
        binarySteps = 4,
        stepSize    = 0.125,
        thickness   = 0.2,
        maxDistance = 4.0,
        edgeFade    = 0.25,
        enabled     = false,
    },
    bloom = {
        mode          = .DISABLED,
        levels        = 0.5,
        intensity     = 0.05,
        threshold     = 0.0,
        softThreshold = 0.5,
        filterRadius  = 1.0,
    },

    fog = {
        mode      = .DISABLED,
        color     = {255, 255, 255, 255},
        start     = 1.0,
        end       = 50.0,
        density   = 0.05,
        skyAffect = 0.5,
    },
    dof = {
        mode        = .DISABLED,
        focusPoint  = 10.0,
        focusScale  = 1.0,
        maxBlurSize = 20.0,
        debugMode   = false,
    },
    tonemap = {
        mode     = .LINEAR,
        exposure = 1.0,
        white    = 1.0,
    },
    color = {
        brightness = 1.0,
        contrast   = 1.0,
        saturation = 1.0,
    },
}
