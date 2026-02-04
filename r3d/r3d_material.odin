/* r3d_material.odin -- R3D Material Module.
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
 * @brief Transparency modes.
 *
 * This enumeration defines how a material handles transparency during rendering.
 * It controls whether transparency is disabled, rendered using a depth pre-pass,
 * or rendered with standard alpha blending.
 */
TransparencyMode :: enum u32 {
    DISABLED = 0, ///< No transparency, supports alpha cutoff.
    PREPASS  = 1, ///< Supports transparency with shadows. Writes shadows for alpha > 0.1 and depth for alpha > 0.99.
    ALPHA    = 2, ///< Standard transparency without shadows or depth writes.
}

/**
 * @brief Billboard modes.
 *
 * This enumeration defines how a 3D object aligns itself relative to the camera.
 * It provides options to disable billboarding or to enable specific modes of alignment.
 */
BillboardMode :: enum u32 {
    DISABLED = 0, ///< Billboarding is disabled; the object retains its original orientation.
    FRONT    = 1, ///< Full billboarding; the object fully faces the camera, rotating on all axes.
    Y_AXIS   = 2, /**< Y-axis constrained billboarding; the object rotates only around the Y-axis,
                                         keeping its "up" orientation fixed. This is suitable for upright objects like characters or signs. */
}

/**
 * @brief Blend modes.
 *
 * Defines common blending modes used in 3D rendering to combine source and destination colors.
 * @note The blend mode is applied only if you are in forward rendering mode or auto-detect mode.
 */
BlendMode :: enum u32 {
    MIX                 = 0, ///< Default mode: the result will be opaque or alpha blended depending on the transparency mode.
    ADDITIVE            = 1, ///< Additive blending: source color is added to the destination, making bright effects.
    MULTIPLY            = 2, ///< Multiply blending: source color is multiplied with the destination, darkening the image.
    PREMULTIPLIED_ALPHA = 3, ///< Premultiplied alpha blending: source color is blended with the destination assuming the source color is already multiplied by its alpha.
}

/**
 * @brief Depth comparison modes.
 *
 * Defines how fragments are tested against the depth buffer during rendering.
 * @note The depth mode affects both forward and deferred rendering passes.
 */
DepthMode :: enum u32 {
    LESS     = 0, ///< Passes if depth < depth buffer (default)
    LEQUAL   = 1, ///< Passes if depth <= depth buffer
    EQUAL    = 2, ///< Passes if depth == depth buffer
    GREATER  = 3, ///< Passes if depth > depth buffer
    GEQUAL   = 4, ///< Passes if depth >= depth buffer
    NOTEQUAL = 5, ///< Passes if depth != depth buffer
    ALWAYS   = 6, ///< Always passes
    NEVER    = 7, ///< Never passes
}

/**
 * @brief Face culling modes.
 *
 * Specifies which faces of a geometry are discarded during rendering based on their winding order.
 */
CullMode :: enum u32 {
    NONE  = 0, ///< No culling; all faces are rendered.
    BACK  = 1, ///< Cull back-facing polygons (faces with clockwise winding order).
    FRONT = 2, ///< Cull front-facing polygons (faces with counter-clockwise winding order).
}

/**
 * @brief Albedo (base color) map.
 *
 * Provides the base color texture and a color multiplier.
 */
AlbedoMap :: struct {
    texture: rl.Texture2D, ///< Base color texture (default: WHITE)
    color:   rl.Color,     ///< rl.Color multiplier (default: WHITE)
}

/**
 * @brief Emission map.
 *
 * Provides emission texture, color, and energy multiplier.
 */
EmissionMap :: struct {
    texture: rl.Texture2D, ///< Emission texture (default: WHITE)
    color:   rl.Color,     ///< Emission color (default: WHITE)
    energy:  f32,       ///< Emission strength (default: 0.0f)
}

/**
 * @brief Normal map.
 *
 * Provides normal map texture and scale factor.
 */
NormalMap :: struct {
    texture: rl.Texture2D, ///< Normal map texture (default: Front Facing)
    scale:   f32,       ///< Normal scale (default: 1.0f)
}

/**
 * @brief Combined Occlusion-Roughness-Metalness (ORM) map.
 *
 * Provides texture and individual multipliers for occlusion, roughness, and metalness.
 */
OrmMap :: struct {
    texture:   rl.Texture2D, ///< ORM texture (default: WHITE)
    occlusion: f32,       ///< Occlusion multiplier (default: 1.0f)
    roughness: f32,       ///< Roughness multiplier (default: 1.0f)
    metalness: f32,       ///< Metalness multiplier (default: 0.0f)
}

/**
 * @brief Material definition.
 *
 * Combines multiple texture maps and rendering parameters for shading.
 */
Material :: struct {
    albedo:           AlbedoMap,        ///< Albedo map
    emission:         EmissionMap,      ///< Emission map
    normal:           NormalMap,        ///< Normal map
    orm:              OrmMap,           ///< Occlusion-Roughness-Metalness map
    uvOffset:         rl.Vector2,          ///< UV offset (default: {0.0f, 0.0f})
    uvScale:          rl.Vector2,          ///< UV scale (default: {1.0f, 1.0f})
    alphaCutoff:      f32,              ///< Alpha cutoff threshold (default: 0.01f)
    transparencyMode: TransparencyMode, ///< Transparency mode (default: DISABLED)
    billboardMode:    BillboardMode,    ///< Billboard mode (default: DISABLED)
    blendMode:        BlendMode,        ///< Blend mode (default: MIX)
    depthMode:        DepthMode,        ///< Depth mode (default: LESS)
    cullMode:         CullMode,         ///< Face culling mode (default: BACK)
    unlit:            bool,             ///< If true, material does not participate in lighting (default: false)
    shader:           ^SurfaceShader,   ///< Custom shader applied to the material (default: NULL)
}

@(default_calling_convention="c", link_prefix="R3D_")
foreign lib {
    /**
     * @brief Get the default material configuration.
     *
     * Returns `R3D_MATERIAL_BASE` by default,
     * or the material defined via `R3D_SetDefaultMaterial()`.
     *
     * @return Default material structure with standard properties.
     */
    GetDefaultMaterial :: proc() -> Material ---

    /**
     * @brief Set the default material configuration.
     *
     * Allows you to override the default material.
     * The default material will be used as the basis for loading 3D models.
     *
     * @param material Default material to define.
     */
    SetDefaultMaterial :: proc(material: Material) ---

    /**
     * @brief Unload a material and its associated textures.
     *
     * Frees all memory associated with a material, including its textures.
     * This function will unload all textures that are not default textures.
     *
     * @warning Only call this function if you are certain that the textures
     * are not shared with other materials or objects, as this will permanently
     * free the texture data.
     *
     * @param material Pointer to the material structure to be unloaded.
     */
    UnloadMaterial :: proc(material: Material) ---

    /**
     * @brief Load an albedo (base color) map from file.
     *
     * Loads an image, uploads it as an sRGB texture (if enabled),
     * and applies the provided tint color.
     *
     * @param fileName Path to the texture file.
     * @param color Multiplicative tint applied in the shader.
     * @return Albedo map structure. Returns an empty map on failure.
     */
    LoadAlbedoMap :: proc(fileName: cstring, color: rl.Color) -> AlbedoMap ---

    /**
     * @brief Load an albedo (base color) map from memory.
     *
     * Same behavior as R3D_LoadAlbedoMap(), but reads from memory instead of disk.
     *
     * @param fileType rl.Image format hint (e.g. "png", "jpg").
     * @param fileData Pointer to image data.
     * @param dataSize Size of image data in bytes.
     * @param color Multiplicative tint applied in the shader.
     * @return Albedo map structure. Returns an empty map on failure.
     */
    LoadAlbedoMapFromMemory :: proc(fileType: cstring, fileData: rawptr, dataSize: i32, color: rl.Color) -> AlbedoMap ---

    /**
     * @brief Unload an albedo map texture.
     *
     * Frees the underlying texture unless it is a default texture.
     *
     * @param map Albedo map to unload.
     */
    UnloadAlbedoMap :: proc(_map: AlbedoMap) ---

    /**
     * @brief Load an emission map from file.
     *
     * Loads an emissive texture (sRGB if enabled) and sets color + energy.
     *
     * @param fileName Path to the texture file.
     * @param color Emission color.
     * @param energy Emission intensity multiplier.
     * @return Emission map. Returns an empty map on failure.
     */
    LoadEmissionMap :: proc(fileName: cstring, color: rl.Color, energy: f32) -> EmissionMap ---

    /**
     * @brief Load an emission map from memory.
     *
     * Same behavior as R3D_LoadEmissionMap(), but reads from memory.
     *
     * @param fileType rl.Image format hint.
     * @param fileData Pointer to image data.
     * @param dataSize Size of image data in bytes.
     * @param color Emission color.
     * @param energy Emission intensity multiplier.
     * @return Emission map. Returns an empty map on failure.
     */
    LoadEmissionMapFromMemory :: proc(fileType: cstring, fileData: rawptr, dataSize: i32, color: rl.Color, energy: f32) -> EmissionMap ---

    /**
     * @brief Unload an emission map texture.
     *
     * Frees the texture unless it is a default texture.
     *
     * @param map Emission map to unload.
     */
    UnloadEmissionMap :: proc(_map: EmissionMap) ---

    /**
     * @brief Load a normal map from file.
     *
     * Uploads the texture in linear space and stores the normal scale factor.
     *
     * @param fileName Path to the texture file.
     * @param scale Normal intensity multiplier.
     * @return Normal map. Returns an empty map on failure.
     */
    LoadNormalMap :: proc(fileName: cstring, scale: f32) -> NormalMap ---

    /**
     * @brief Load a normal map from memory.
     *
     * Same behavior as R3D_LoadNormalMap(), but reads from memory.
     *
     * @param fileType rl.Image format hint.
     * @param fileData Pointer to image data.
     * @param dataSize Size of image data in bytes.
     * @param scale Normal intensity multiplier.
     * @return Normal map. Returns an empty map on failure.
     */
    LoadNormalMapFromMemory :: proc(fileType: cstring, fileData: rawptr, dataSize: i32, scale: f32) -> NormalMap ---

    /**
     * @brief Unload a normal map texture.
     *
     * Frees the texture unless it is a default texture.
     *
     * @param map Normal map to unload.
     */
    UnloadNormalMap :: proc(_map: NormalMap) ---

    /**
     * @brief Load a combined ORM (Occlusion-Roughness-Metalness) map from file.
     *
     * Uploads the texture in linear space and applies the provided multipliers.
     *
     * @param fileName Path to the ORM texture.
     * @param occlusion Occlusion multiplier.
     * @param roughness Roughness multiplier.
     * @param metalness Metalness multiplier.
     * @return ORM map. Returns an empty map on failure.
     */
    LoadOrmMap :: proc(fileName: cstring, occlusion: f32, roughness: f32, metalness: f32) -> OrmMap ---

    /**
     * @brief Load a combined ORM (Occlusion-Roughness-Metalness) map from memory.
     *
     * Same behavior as R3D_LoadOrmMap(), but reads from memory.
     *
     * @param fileType rl.Image format hint.
     * @param fileData Pointer to image data.
     * @param dataSize Size of image data in bytes.
     * @param occlusion Occlusion multiplier.
     * @param roughness Roughness multiplier.
     * @param metalness Metalness multiplier.
     * @return ORM map. Returns an empty map on failure.
     */
    LoadOrmMapFromMemory :: proc(fileType: cstring, fileData: rawptr, dataSize: i32, occlusion: f32, roughness: f32, metalness: f32) -> OrmMap ---

    /**
     * @brief Unload an ORM map texture.
     *
     * Frees the texture unless it is a default texture.
     *
     * @param map ORM map to unload.
     */
    UnloadOrmMap :: proc(_map: OrmMap) ---
}

/**
 * @brief Default material configuration.
 *
 * Initializes an R3D_Material structure with sensible default values for all
 * rendering parameters. Use this as a starting point for custom configurations.
 */
MATERIAL_BASE :: Material {
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
    transparencyMode = .DISABLED,
    billboardMode = .DISABLED,
    blendMode = .MIX,
    depthMode = .LESS,
    cullMode = .BACK,
    shader = nil,
}
