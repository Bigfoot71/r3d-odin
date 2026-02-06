/* r3d_utils.odin -- R3D Utility Module.
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

@(default_calling_convention="c", link_prefix="R3D_")
foreign lib {
    /**
     * @brief Retrieves a default white texture.
     *
     * This texture is fully white (1,1,1,1), useful for default material properties.
     *
     * @return A white texture.
     */
    GetWhiteTexture :: proc() -> rl.Texture2D ---

    /**
     * @brief Retrieves a default black texture.
     *
     * This texture is fully black (0,0,0,1), useful for masking or default values.
     *
     * @return A black texture.
     */
    GetBlackTexture :: proc() -> rl.Texture2D ---

    /**
     * @brief Retrieves a default normal map texture.
     *
     * This texture represents a neutral normal map (0.5, 0.5, 1.0), which applies no normal variation.
     *
     * @return A neutral normal texture.
     */
    GetNormalTexture :: proc() -> rl.Texture2D ---

    /**
     * @brief Retrieves the buffer containing the scene's normal data.
     *
     * This texture stores octahedral-compressed normals using two 16-bit per-channel RG components.
     *
     * @note You can find the decoding functions in the embedded shaders, such as 'screen/lighting.fs.glsl'.
     *
     * @return The normal buffer texture.
     */
    GetBufferNormal :: proc() -> rl.Texture2D ---

    /**
     * @brief Retrieves the final depth buffer.
     *
     * This texture is an R16 texture containing a linear depth value
     * normalized between the near and far clipping planes.
     * It does not include a stencil buffer.
     *
     * The texture is intended for post-processing effects outside of R3D
     * that require access to linear depth information.
     *
     * @return The final depth buffer texture (R16, linear depth).
     */
    GetBufferDepth :: proc() -> rl.Texture2D ---

    /**
     * @brief Retrieves the view matrix.
     *
     * This matrix represents the camera's transformation from world space to view space.
     * It is updated at the last call to 'R3D_Begin'.
     *
     * @return The current view matrix.
     */
    GetMatrixView :: proc() -> rl.Matrix ---

    /**
     * @brief Retrieves the inverse view matrix.
     *
     * This matrix transforms coordinates from view space back to world space.
     * It is updated at the last call to 'R3D_Begin'.
     *
     * @return The current inverse view matrix.
     */
    GetMatrixInvView :: proc() -> rl.Matrix ---

    /**
     * @brief Retrieves the projection matrix.
     *
     * This matrix defines the transformation from view space to clip space.
     * It is updated at the last call to 'R3D_Begin'.
     *
     * @return The current projection matrix.
     */
    GetMatrixProjection :: proc() -> rl.Matrix ---

    /**
     * @brief Retrieves the inverse projection matrix.
     *
     * This matrix transforms coordinates from clip space back to view space.
     * It is updated at the last call to 'R3D_Begin'.
     *
     * @return The current inverse projection matrix.
     */
    GetMatrixInvProjection :: proc() -> rl.Matrix ---
}

