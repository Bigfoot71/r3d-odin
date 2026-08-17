/* r3d_lighting.odin -- R3D Lighting Module.
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
 * @brief Types of lights supported by the rendering engine.
 *
 * Each light type has different behaviors and use cases.
 */
LightType :: enum u32 {
    DIR        = 0, ///< Directional light, affects the entire scene with parallel rays.
    SPOT       = 1, ///< Spot light, emits light in a cone shape.
    OMNI       = 2, ///< Omni light, emits light in all directions from a single point.
    TYPE_COUNT = 3,
}

/**
 * @brief Describes a light source.
 */
Light :: struct {
    position:    rl.Vector3,   ///< Light position (spot/omni)
    direction:   rl.Vector3,   ///< Light direction (spot/dir)
    color:       rl.Color,     ///< Light color
    energy:      f32,       ///< Light intensity/brightness multiplier
    specular:    f32,       ///< Specular reflection intensity multiplier
    range:       f32,       ///< Maximum distance (spot/omni)
    falloff:     f32,       ///< Distance falloff factor (spot/omni)
    innerCutOff: f32,       ///< Spot light inner cutoff angle (degrees)
    outerCutOff: f32,       ///< Spot light outer cutoff angle (degrees)
    fogEnergy:   f32,       ///< Volumetric fog energy multiplier
    type:        LightType, ///< Light type (directional/spot/omni)
}

/**
 * @brief Represents an allocated shadow map for a light.
 */
ShadowMap :: struct {
    handle:    u32,       ///< Internal shadow map handle (don't touch)
    softness:  f32,       ///< Softness factor for penumbra
    opacity:   f32,       ///< Shadow opacity factor
    depthBias: f32,       ///< Constant depth bias
    slopeBias: f32,       ///< Slope-scaled depth bias
    cullMask:  Layer,     ///< Layers considered when culling shadow casters for this map
    type:      LightType, ///< Light type this shadow map was allocated for
}

@(default_calling_convention="c", link_prefix="R3D_")
foreign lib {
    /**
     * @brief Creates a directional light.
     */
    CreateDirLight :: proc(dir: rl.Vector3, color: rl.Color, energy: f32) -> Light ---

    /**
     * @brief Creates a spot light, with default inner/outer cutoff angles of 22.5/45 degrees.
     */
    CreateSpotLight :: proc(pos: rl.Vector3, dir: rl.Vector3, range: f32, color: rl.Color, energy: f32) -> Light ---

    /**
     * @brief Creates an omnidirectional (point) light.
     */
    CreateOmniLight :: proc(pos: rl.Vector3, range: f32, color: rl.Color, energy: f32) -> Light ---

    /**
     * @brief Allocates a shadow map layer for a given light type.
     *
     * The shadow map resolution is fixed per light type and configured via
     * R3D_HINT_SHADOW_DIR_SIZE, R3D_HINT_SHADOW_SPOT_SIZE and R3D_HINT_SHADOW_OMNI_SIZE
     * before R3D is initialized.
     *
     * @param type The light type this shadow map will be used with (must match
     *             the type of the light it is later passed to via R3D_PushLight()).
     */
    LoadShadowMap :: proc(type: LightType) -> ShadowMap ---

    /**
     * @brief Releases a shadow map, freeing its layer for reuse.
     */
    UnloadShadowMap :: proc(shadowMap: ShadowMap) ---

    /**
     * @brief Returns whether the shadow map has a valid allocated layer.
     */
    IsShadowMapValid :: proc(shadowMap: ShadowMap) -> bool ---

    /**
     * @brief Draws the area of influence of the light in 3D space.
     *
     * This function visualizes the area affected by a light in 3D space.
     * It draws the light's influence, such as the cone for spotlights or the volume for omni-lights.
     * This function is only relevant for spotlights and omni-lights.
     *
     * @note This function should be called while using the default 3D rendering mode of raylib,
     *       not with r3d's rendering mode. It uses raylib's 3D drawing functions to render the light's shape.
     *
     * @param light The light to visualize (see R3D_Light).
     */
    DrawLightDebug :: proc(light: Light) ---
}

