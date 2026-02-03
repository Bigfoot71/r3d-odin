/* r3d_importer.odin -- R3D Importer Module.
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

Importer :: struct {}

@(default_calling_convention="c", link_prefix="R3D_")
foreign lib {
    /**
     * @brief Load an importer from a file.
     *
     * Creates an importer instance from the specified file path.
     * The file is parsed once and can be reused to extract multiple
     * resources such as models and animations.
     *
     * @param filePath Path to the asset file.
     * @param flags Importer behavior flags.
     *
     * @return Pointer to a new importer instance, or NULL on failure.
     */
    LoadImporter :: proc(filePath: cstring, flags: ImportFlags) -> ^Importer ---

    /**
     * @brief Load an importer from a memory buffer.
     *
     * Creates an importer instance from in-memory asset data.
     * This is useful for embedded assets or streamed content.
     *
     * @param data Pointer to the asset data.
     * @param size Size of the data buffer in bytes.
     * @param hint Optional file format hint (may be NULL).
     * @param flags Importer behavior flags.
     *
     * @return Pointer to a new importer instance, or NULL on failure.
     */
    LoadImporterFromMemory :: proc(data: rawptr, size: u32, hint: cstring, flags: ImportFlags) -> ^Importer ---

    /**
     * @brief Destroy an importer instance.
     *
     * Frees all resources associated with the importer.
     * Any models or animations extracted from it remain valid.
     *
     * @param importer Importer instance to destroy.
     */
    UnloadImporter :: proc(importer: ^Importer) ---
}

/**
 * @typedef R3D_ImportFlags
 * @brief Flags controlling importer behavior.
 *
 * These flags define how the importer processes the source asset.
 */
ImportFlag :: enum u32 {

    /**
     * @brief Keep a CPU-side copy of mesh data.
     *
     * When enabled, raw mesh data is preserved in RAM after model import.
     */
    MESH_DATA = 0,

    /**
     * @brief Enable high-quality import processing.
     *
     * When enabled, the importer uses a higher-quality post-processing
     * (e.g. smooth normals, mesh optimization, data validation).
     * This mode is intended for editor usage and offline processing.
     *
     * When disabled, a faster import preset is used, suitable for runtime.
     */
    QUALITY = 1,

}

ImportFlags :: bit_set[ImportFlag; u32]
