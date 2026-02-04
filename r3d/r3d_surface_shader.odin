/* r3d_surface_shader.odin -- R3D Surface Shader Module.
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

SurfaceShader :: struct {}

@(default_calling_convention="c", link_prefix="R3D_")
foreign lib {
    /**
     * @brief Loads a surface shader from a file.
     *
     * The shader must define at least one entry point: `void vertex()` or `void fragment()`.
     * It can define either one or both.
     *
     * @param filePath Path to the shader source file.
     * @return Pointer to the loaded surface shader, or NULL on failure.
     */
    LoadSurfaceShader :: proc(filePath: cstring) -> ^SurfaceShader ---

    /**
     * @brief Loads a surface shader from a source code string in memory.
     *
     * The shader must define at least one entry point: `void vertex()` or `void fragment()`.
     * It can define either one or both.
     *
     * @param code Null-terminated shader source code.
     * @return Pointer to the loaded surface shader, or NULL on failure.
     */
    LoadSurfaceShaderFromMemory :: proc(code: cstring) -> ^SurfaceShader ---

    /**
     * @brief Unloads and destroys a surface shader.
     *
     * @param shader Surface shader to unload.
     */
    UnloadSurfaceShader :: proc(shader: ^SurfaceShader) ---

    /**
     * @brief Sets a uniform value for the current frame.
     *
     * Once a uniform is set, it remains valid for the all frames.
     * If an uniform is set multiple times during the same frame,
     * the last value defined before R3D_End() is used.
     *
     * Supported types:
     * bool, int, float,
     * ivec2, ivec3, ivec4,
     * vec2, vec3, vec4,
     * mat2, mat3, mat4
     *
     * @warning Boolean values are read as 4 bytes.
     *
     * @param shader Target surface shader.
     * @param name Name of the uniform.
     * @param value Pointer to the uniform value.
     */
    SetSurfaceShaderUniform :: proc(shader: ^SurfaceShader, name: cstring, value: rawptr) ---

    /**
     * @brief Sets a texture sampler for the current frame.
     *
     * Once a sampler is set, it remains valid for all frames.
     * If a sampler is set multiple times during the same frame,
     * the last value defined before R3D_End() is used.
     *
     * Supported samplers:
     * sampler1D, sampler2D, sampler3D, samplerCube
     *
     * @param shader Target surface shader.
     * @param name Name of the sampler uniform.
     * @param texture rl.Texture to bind to the sampler.
     */
    SetSurfaceShaderSampler :: proc(shader: ^SurfaceShader, name: cstring, texture: rl.Texture) ---
}

