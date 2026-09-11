/* r3d_vertex.odin -- R3D Vertex Module.
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

/**
 * @brief Compact vertex format used by R3D meshes.
 *
 * rl.Texture coordinates are stored as float16 values.
 * Normals and tangents are stored as signed normalized 8-bit values.
 * Bone weights are stored as unsigned 8-bit values and should sum to 255.
 */
Vertex :: struct {
    position:    rl.Vector3, ///< Vertex position in object space.
    texcoord:    [2]u16,  ///< rl.Texture coordinates stored as float16.
    normal:      [4]i8,   ///< Normal vector stored as SNORM8. XYZ are used, W is unused.
    tangent:     [4]i8,   ///< Tangent vector stored as SNORM8. XYZ are tangent, W stores handedness.
    color:       rl.Color,   ///< Vertex color in RGBA8.
    boneIndices: [4]u8,   ///< Indices of up to 4 bones influencing this vertex.
    boneWeights: [4]u8,   ///< Bone weights in UNORM8. Values should sum to 255.
}

@(default_calling_convention="c", link_prefix="R3D_")
foreign lib {
    /**
     * @brief Constructs a packed R3D vertex from unpacked attribute data.
     *
     * rl.Texture coordinates are packed to float16.
     * Normals and tangents are packed to SNORM8.
     *
     * @param position Vertex position in object space.
     * @param texcoord rl.Texture coordinates in float32. Any range is supported.
     * @param normal Normal vector. Components are clamped to the [-1, 1] range.
     * @param tangent Tangent vector. XYZ components are clamped to [-1, 1], W stores handedness.
     * @param color Vertex color in RGBA8.
     *
     * @return Packed vertex ready for GPU upload.
     */
    MakeVertex :: proc(position: rl.Vector3, texcoord: rl.Vector2, normal: rl.Vector3, tangent: rl.Vector4, color: rl.Color) -> Vertex ---

    /**
     * @brief Packs texture coordinates from float32 to float16.
     *
     * @param dst Output buffer of 2 uint16_t values. Must not be NULL.
     * @param src rl.Texture coordinates in float32. Any range is supported.
     */
    PackTexCoord :: proc(dst: ^u16, src: rl.Vector2) ---

    /**
     * @brief Unpacks texture coordinates from float16 to float32.
     *
     * @param src Input buffer of 2 uint16_t values. Must not be NULL.
     *
     * @return Unpacked texture coordinates in float32.
     */
    UnpackTexCoord :: proc(src: ^u16) -> rl.Vector2 ---

    /**
     * @brief Packs a normal vector from float32 to SNORM8.
     *
     * XYZ components are clamped to the [-1, 1] range before packing.
     * The fourth component is set to 0.
     *
     * @param dst Output buffer of 4 int8_t values. Must not be NULL.
     * @param src Normal vector to pack.
     */
    PackNormal :: proc(dst: ^i8, src: rl.Vector3) ---

    /**
     * @brief Unpacks a normal vector from SNORM8 to float32.
     *
     * Only XYZ components are read.
     *
     * @param src Input buffer of 4 int8_t values. Must not be NULL.
     *
     * @return Unpacked normal vector. Not guaranteed to be unit length.
     */
    UnpackNormal :: proc(src: ^i8) -> rl.Vector3 ---

    /**
     * @brief Packs a tangent vector from float32 to SNORM8.
     *
     * XYZ components are clamped to the [-1, 1] range before packing.
     * W stores tangent handedness and is packed as either +1 or -1.
     *
     * @param dst Output buffer of 4 int8_t values. Must not be NULL.
     * @param src Tangent vector to pack. W is interpreted as handedness.
     */
    PackTangent :: proc(dst: ^i8, src: rl.Vector4) ---

    /**
     * @brief Unpacks a tangent vector from SNORM8 to float32.
     *
     * XYZ components are unpacked from SNORM8.
     * W is returned as exactly +1.0f or -1.0f.
     *
     * @param src Input buffer of 4 int8_t values. Must not be NULL.
     *
     * @return Unpacked tangent vector.
     */
    UnpackTangent :: proc(src: ^i8) -> rl.Vector4 ---
}

