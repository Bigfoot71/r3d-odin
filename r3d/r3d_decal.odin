/* r3d_decal.odin -- R3D Decal Module.
 *
 * Copyright (c) 2025 Le Juez Victor
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
 * @brief Represents a decal and its properties.
 *
 * This structure defines a decal that can be projected onto geometry that has already been rendered.
 *
 * @note Decals are drawn using deferred screen space rendering and do not interact with any
 * forward rendered or non-opaque objects.
 */
Decal :: struct {
    albedo:          AlbedoMap,      ///< Albedo map (if the texture is undefined, implicitly treat `applyColor` as false, with alpha = 1.0)
    emission:        EmissionMap,    ///< Emission map
    normal:          NormalMap,      ///< Normal map
    orm:             OrmMap,         ///< Occlusion-Roughness-Metalness map
    uvOffset:        rl.Vector2,        ///< UV offset (default: {0.0f, 0.0f})
    uvScale:         rl.Vector2,        ///< UV scale (default: {1.0f, 1.0f})
    alphaCutoff:     f32,            ///< Alpha cutoff threshold (default: 0.01f)
    normalThreshold: f32,            ///< Maximum angle against the surface normal to draw decal. 0.0f disables threshold. (default: 0.0f)
    fadeWidth:       f32,            ///< The width of fading along the normal threshold (default: 0.0f)
    applyColor:      bool,           ///< Indicates that the albedo color will not be rendered, only the alpha component of the albedo will be used as a mask. (default: true)
    shader:          ^SurfaceShader, ///< Custom shader applied to the decal (default: NULL)
}

@(default_calling_convention="c", link_prefix="R3D_")
foreign lib {
    /**
     * @brief Unload all map textures assigned to a R3D_Decal.
     *
     * Frees all underlying textures in a R3D_Decal that are not a default texture.
     *
     * @param decal to unload maps from.
     */
    UnloadDecalMaps :: proc(decal: Decal) ---
}

/**
 * @brief Default decal configuration.
 *
 * Contains a R3D_Decal structure with sensible default values for all rendering parameters.
 */
DECAL_BASE :: Decal {
    albedo = {
        texture = {},
        color = {255, 255, 255, 255},
    },
    emission = {
        texture = {},
        color = {255, 255, 255, 255},
        energy = 0.0,
    },
    normal = {
        texture = {},
        scale = 1.0,
    },
    orm = {
        texture = {},
        occlusion = 1.0,
        roughness = 1.0,
        metalness = 0.0,
    },
    uvOffset = {0.0, 0.0},
    uvScale = {1.0, 1.0},
    alphaCutoff = 0.01,
    normalThreshold = 0,
    fadeWidth = 0,
    applyColor = true,
    shader = nil,
}
