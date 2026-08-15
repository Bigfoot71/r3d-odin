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
    power:       f32,  ///< Exponential falloff for sharper darkening (default: 1.0)
    radius:      f32,  ///< Sampling radius in world space (default: 1.0)
    bias:        f32,  ///< Depth bias to prevent self-occlusion artifacts, in world-space units (default: 0.03)
    enabled:     bool, ///< Enable/disable SSAO effect (default: false)
}

/**
 * @brief Screen Space Indirect Lighting (SSIL) settings.
 *
 * Extends the SSAO algorithm with a global illumination component: occluding
 * surfaces not only darken the fragment (ambient occlusion) but also transfer
 * their color to it (indirect light bounce). A larger radius than SSAO is
 * generally preferable to capture meaningful indirect lighting contributions.
 */
EnvSSIL :: struct {
    sampleCount: i32,  ///< Number of samples to compute SSIL (default: 16)
    giIntensity: f32,  ///< Indirect light strength multiplier (default: 1.0)
    aoIntensity: f32,  ///< Ambient occlusion strength multiplier (default: 1.0)
    aoPower:     f32,  ///< Exponential falloff for sharper occlusion darkening (default: 1.0)
    radius:      f32,  ///< Sampling radius in world space (default: 4.0)
    bias:        f32,  ///< Depth bias to prevent self-occlusion artifacts, in world-space units (default: 0.03)
    enabled:     bool, ///< Enable/disable SSIL effect (default: false)
}

/**
 * @brief Screen Space Global Illumination (SSGI) settings.
 *
 * Computes indirect lighting from the scene's visible surfaces in real time.
 */
EnvSSGI :: struct {
    sliceCount:      i32,  ///< Number of directions sampled per pixel. Higher = fewer noise streaks, higher cost. (default: 4)
    edgeFade:        f32,  ///< Fades out GI near screen edges to hide emissive objects partially off-screen. (default: 0.1)
    distanceFalloff: f32,  ///< How quickly indirect light fades with distance. Higher = shorter reach, darker result. (default: 1.0)
    normalRejection: f32,  ///< Prevents surfaces from receiving light through their own backside. 0 = off, 1 = physically correct. May look inconsistent with non-directional emissives. (default: 0.0)
    intensity:       f32,  ///< Brightness of the indirect lighting. Dimly lit scenes may require significantly higher values to show probable contribution. (default: 1.0)
    denoiseSteps:    i32,  ///< Number of denoiser passes. Higher = smoother result, slightly higher cost. (default: 4)
    enabled:         bool, ///< Enable or disable SSGI entirely. (default: false)
}

/**
 * @brief Screen Space Reflections (SSR) settings.
 *
 * Real-time reflections calculated in screen space.
 */
EnvSSR :: struct {
    maxIterations: i32,  ///< Maximum ray marching iterations (default: 64)
    thickness:     f32,  ///< Depth tolerance for valid hits (default: 0.5)
    edgeFade:      f32,  ///< Screen edge fade start [0,1] (default: 0.25)
    enabled:       bool, ///< Enable/disable SSR (default: false)
}

/**
 * @brief Atmospheric fog effect settings.
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
 * @brief Volumetric fog effect settings.
 */
VolumetricFog :: struct {
    scatteringDensity: f32,   ///< Light scattering thickness; higher = more visible light rays (default: 0.01)
    absortionDensity:  f32,   ///< Light absorption thickness; higher = darker scene (default: 0.03)
    scatteringColor:   rl.Color, ///< Tint color of scattered light rays (default: WHITE)
    anisotropy:        f32,   ///< Scattering direction: 0 = uniform, >0 = forward (haze), <0 = backward (default: 0.5)
    emissionColor:     rl.Color, ///< rl.Color emitted by the fog regardless of lighting (default: WHITE)
    emissionEnergy:    f32,   ///< Emission brightness; 0 disables emission (default: 0.0)
    skyAffect:         f32,   ///< Fog influence on the skybox [0-1] (default: 0.5)
    length:            f32,   ///< Maximum fog render distance in world units (default: 50.0)
    stepSize:          f32,   ///< rl.Ray-march step size; smaller = higher quality, lower performance (default: 1.0)
    enabled:           bool,  ///< Enables or disables the volumetric fog (default: false)
}

/**
 * @brief Depth of Field (DoF) camera focus settings.
 *
 * Blurs objects outside the focal plane.
 */
EnvDoF :: struct {
    mode:        DoF, ///< Enable/disable state (default: R3D_DOF_DISABLED)
    focusPoint:  f32, ///< Focus distance in meters from camera (default: 10.0)
    focusScale:  f32, ///< Depth of field depth: lower = shallower (default: 1.0)
    nearScale:   f32, ///< Near blur intensity: 0.0 = disabled, 1.0 = symmetric to far (default: 1.0)
    maxBlurSize: f32, ///< Maximum blur radius, similar to aperture (default: 20.0)
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
 * @brief Auto exposure post-processing settings.
 *
 * Automatically adjusts scene exposure from average luminance,
 * simulating eye adaptation. Adaptation should physically be
 * faster toward bright scenes than toward dark scenes,
 * as dark adaptation is slower.
 *
 * @warning Current implementation keeps a single temporal history. Enabling
 * auto exposure for multiple scene passes in the same frame, or across
 * different scenes, may produce incorrect adaptation. For now, use it only on
 * one continuous begin/end scene render path.
 */
EnvAutoExposure :: struct {
    minEV:                f32,  ///< Minimum measured luminance in EV stops, relative to middle gray (default: -1.0)
    maxEV:                f32,  ///< Maximum measured luminance in EV stops, relative to middle gray (default:  1.0)
    exposureCompensation: f32,  ///< Artistic exposure bias in EV stops: +1 = one stop brighter (default: 0.0)
    adaptationToBright:   f32,  ///< Time constant in seconds when scene luminance increases; lower = faster (default: 0.5)
    adaptationToDark:     f32,  ///< Time constant in seconds when scene luminance decreases; lower = faster (default: 1.0)
    enabled:              bool, ///< Enable auto exposure (default: false)
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
    background:    EnvBackground,   ///< Background and skybox settings
    ambient:       EnvAmbient,      ///< Ambient lighting configuration
    ssao:          EnvSSAO,         ///< Screen space ambient occlusion
    ssil:          EnvSSIL,         ///< Screen space indirect lighting
    ssgi:          EnvSSGI,         ///< Screen space global illumination
    ssr:           EnvSSR,          ///< Screen space reflections
    fog:           EnvFog,          ///< Atmospheric fog
    volumetricFog: VolumetricFog,   ///< Volumetric fog
    dof:           EnvDoF,          ///< Depth of field focus effect
    bloom:         EnvBloom,        ///< Bloom glow effect
    autoExposure:  EnvAutoExposure, ///< Auto exposure effect
    tonemap:       EnvTonemap,      ///< HDR tone mapping
    color:         EnvColor,        ///< rl.Color grading adjustments
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
        power       = 1.0,
        radius      = 1.0,
        bias        = 0.03,
        enabled     = false,
    },
    ssil = {
        sampleCount = 16,
        giIntensity = 1.0,
        aoIntensity = 1.0,
        aoPower     = 1.0,
        radius      = 4.0,
        bias        = 0.03,
        enabled     = false,
    },
    ssgi = {
        sliceCount      = 4,
        edgeFade        = 0.1,
        distanceFalloff = 1.0,
        normalRejection = 0.0,
        intensity       = 1.0,
        denoiseSteps    = 4,
        enabled         = false,
    },
    ssr = {
        maxIterations = 64,
        thickness     = 0.5,
        edgeFade      = 0.25,
        enabled       = false,
    },
    fog = {
        mode      = .DISABLED,
        color     = rl.WHITE,
        start     = 1.0,
        end       = 50.0,
        density   = 0.05,
        skyAffect = 0.5,
    },
    volumetricFog = {
        scatteringDensity = 0.01,
        absortionDensity  = 0.03,
        scatteringColor   = rl.WHITE,
        anisotropy        = 0.5,
        emissionColor     = rl.WHITE,
        emissionEnergy    = 0.0,
        skyAffect         = 0.5,
        length            = 50.0,
        stepSize          = 1.0,
        enabled           = false,
    },
    dof = {
        mode        = .DISABLED,
        focusPoint  = 10.0,
        focusScale  = 1.0,
        nearScale   = 1.0,
        maxBlurSize = 20.0,
    },
    bloom = {
        mode          = .DISABLED,
        levels        = 0.5,
        intensity     = 0.05,
        threshold     = 0.0,
        softThreshold = 0.5,
        filterRadius  = 1.0,
    },
    autoExposure = {
        minEV                = -1.0,
        maxEV                = 1.0,
        exposureCompensation = 0.0,
        adaptationToBright   = 0.5,
        adaptationToDark     = 1.0,
        enabled              = false,
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
