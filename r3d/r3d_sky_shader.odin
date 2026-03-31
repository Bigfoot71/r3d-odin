/* r3d_sky_shader.odin -- R3D Sky Shader Module.
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

// ========================================
// OPAQUE TYPES
// ========================================
SkyShader :: struct {}

@(default_calling_convention="c", link_prefix="R3D_")
foreign lib {
    /**
     * @brief Loads a sky shader from a file.
     *
     * The shader must define a single entry point:
     * `void fragment()`. Any other entry point, such as `vertex()`,
     * or any varyings will be ignored.
     *
     * @param filePath Path to the shader source file.
     * @return Pointer to the loaded sky shader, or NULL on failure.
     */
    LoadSkyShader :: proc(filePath: cstring) -> ^SkyShader ---

    /**
     * @brief Loads a sky shader from a source code string in memory.
     *
     * The shader must define a single entry point:
     * `void fragment()`. Any other entry point, such as `vertex()`,
     * or any varyings will be ignored.
     *
     * @param code Null-terminated shader source code.
     * @return Pointer to the loaded sky shader, or NULL on failure.
     */
    LoadSkyShaderFromMemory :: proc(code: cstring) -> ^SkyShader ---

    /**
     * @brief Creates an alias of an existing sky shader.
     *
     * The alias shares the same compiled program as the original but holds its own
     * independent uniform and sampler state. A typical use case is to pre-configure
     * several aliases with different uniforms or textures, avoiding the need to
     * reconfigure the shader on every skybox switch.
     *
     * Uniform and sampler state is copied from the original at the moment this
     * function is called, not from the shader source defaults. Any values set
     * on the original after compilation but before this call will be reflected
     * in the alias; values set afterward will not.
     *
     * @note The alias does not own the program. Always unload all aliases before
     *       unloading the original, or the alias program references become dangling.
     *
     * @param shader The original sky shader to alias.
     * @return Pointer to the alias, or NULL on failure.
     */
    LoadSkyShaderAlias :: proc(shader: ^SkyShader) -> ^SkyShader ---

    /**
     * @brief Unloads and destroys a sky shader.
     *
     * If the shader owns its program shaders (i.e. it was created with @ref R3D_LoadSkyShader
     * or @ref R3D_LoadSkyShaderFromMemory), they are deleted. Aliases created from this
     * shader via @ref R3D_LoadSkyShaderAlias must be unloaded beforehand, as they
     * share the same programs and will be left with dangling references.
     *
     * @param shader Sky shader to unload.
     */
    UnloadSkyShader :: proc(shader: ^SkyShader) ---

    /**
     * @brief Sets a uniform value for all subsequent sky generations.
     *
     * Supported types:
     * bool, int, float,
     * ivec2, ivec3, ivec4,
     * vec2, vec3, vec4,
     * mat2, mat3, mat4
     *
     * @warning Boolean values are read as 4 bytes.
     *
     * @param shader Target sky shader.
     *               May be NULL. In that case, the call is ignored
     *               and a warning is logged.
     * @param name   Name of the uniform. Must not be NULL.
     * @param value  Pointer to the uniform value. Must not be NULL.
     */
    SetSkyShaderUniform :: proc(shader: ^SkyShader, name: cstring, value: rawptr) ---

    /**
     * @brief Sets a uniform value for all subsequent sky generations.
     *
     * Supported samplers:
     * sampler1D, sampler2D, sampler3D, samplerCube
     *
     * @param shader  Target sky shader.
     *                May be NULL. In that case, the call is ignored
     *                and a warning is logged.
     * @param name    Name of the sampler uniform. Must not be NULL.
     * @param texture rl.Texture to bind to the sampler.
     */
    SetSkyShaderSampler :: proc(shader: ^SkyShader, name: cstring, texture: rl.Texture) ---
}

