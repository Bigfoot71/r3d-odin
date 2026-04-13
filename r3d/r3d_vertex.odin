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
        "/macos/libr3d.a",
    }
}

/**
 * @brief Represents a vertex and all its attributes for a mesh.
 */
Vertex :: struct {
    position:    rl.Vector3, ///< The 3D position of the vertex in object space.
    texcoord:    [2]u16,  ///< The 2D texture coordinates (UV) for mapping textures.
    normal:      [4]i8,   ///< The normal vector used for lighting calculations.
    tangent:     [4]i8,   ///< The tangent vector, used in normal mapping (often with a handedness in w).
    color:       rl.Color,   ///< Vertex color, in RGBA32.
    boneIndices: [4]u8,   ///< Indices of up to 4 bones that influence this vertex (for skinning).
    boneWeights: [4]u8,   ///< Corresponding bone weights (should sum to 255). Defines the influence of each bone.
}

@(default_calling_convention="c", link_prefix="R3D_")
foreign lib {
    /**
     * @brief Constructs a fully encoded @ref R3D_Vertex from unpacked attribute data.
     * @param position Vertex position in object space.
     * @param texcoord UV texture coordinates (float, any range).
     * @param normal Unit normal vector.
     * @param tangent Tangent vector with handedness in w (+1 or -1).
     * @param color Vertex color in RGBA8.
     * @return Encoded vertex ready for GPU upload.
     */
    MakeVertex :: proc(position: rl.Vector3, texcoord: rl.Vector2, normal: rl.Vector3, tangent: rl.Vector4, color: rl.Color) -> Vertex ---

    /**
     * @brief Encodes a UV coordinate pair from float32 to float16.
     * @param dst Output buffer of 2 uint16_t (float16). Must not be NULL.
     * @param src UV coordinates in float32. Supports any range (tiling included).
     */
    EncodeTexCoord :: proc(dst: ^u16, src: rl.Vector2) ---

    /**
     * @brief Decodes a float16 UV coordinate pair back to float32.
     * @param src Input buffer of 2 uint16_t (float16). Must not be NULL.
     * @return Decoded UV coordinates in float32.
     */
    DecodeTexCoord :: proc(src: ^u16) -> rl.Vector2 ---

    /**
     * @brief Encodes a unit normal vector from float32 to snorm8 (XYZ).
     * @param dst Output buffer of 4 int8_t. W is set to 0. Must not be NULL.
     * @param src Unit normal vector. Components must be in [-1, 1].
     */
    EncodeNormal :: proc(dst: ^i8, src: rl.Vector3) ---

    /**
     * @brief Decodes a snorm8 normal back to float32.
     * @param src Input buffer of 4 int8_t (only XYZ are read). Must not be NULL.
     * @return Decoded normal vector. Not guaranteed to be unit length.
     */
    DecodeNormal :: proc(src: ^i8) -> rl.Vector3 ---

    /**
     * @brief Encodes a tangent vector from float32 to snorm8, preserving handedness in W.
     * @param dst Output buffer of 4 int8_t. Must not be NULL.
     * @param src Tangent vector. XYZ must be in [-1, 1]; W encodes handedness (+1 or -1).
     */
    EncodeTangent :: proc(dst: ^i8, src: rl.Vector4) ---

    /**
     * @brief Decodes a snorm8 tangent back to float32.
     * @param src Input buffer of 4 int8_t. Must not be NULL.
     * @return Decoded tangent. W is exactly +1.0 or -1.0 (handedness).
     */
    DecodeTangent :: proc(src: ^i8) -> rl.Vector4 ---
}

