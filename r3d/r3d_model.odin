/* r3d_model.odin -- R3D Model Module.
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
 * @brief Represents a complete 3D model with meshes and materials.
 *
 * Contains multiple meshes and their associated materials, along with animation and bounding information.
 */
Model :: struct {
    meshes:        [^]Mesh,     ///< Array of meshes composing the model.
    meshData:      [^]MeshData, ///< Array of meshes data in RAM (optional, can be NULL).
    materials:     [^]Material, ///< Array of materials used by the model.
    meshMaterials: [^]i32,      ///< Array of material indices, one per mesh.
    meshCount:     i32,         ///< Number of meshes.
    materialCount: i32,         ///< Number of materials.
    aabb:          rl.BoundingBox, ///< Axis-Aligned Bounding Box encompassing the whole model.
    skeleton:      Skeleton,    ///< Skeleton hierarchy and bind pose used for skinning (NULL if non-skinned).
}

@(default_calling_convention="c", link_prefix="R3D_")
foreign lib {
    /**
     * @brief Load a 3D model from a file.
     *
     * Loads a 3D model from the specified file path. Supports various 3D file formats
     * and automatically parses meshes, materials, and texture references.
     *
     * @param filePath Path to the 3D model file to load.
     *
     * @return Loaded model structure containing meshes and materials.
     */
    LoadModel :: proc(filePath: cstring) -> Model ---

    /**
     * @brief Load a 3D model from a file with import flags.
     *
     * Extended version of R3D_LoadModel() allowing control over the import
     * process through additional flags.
     *
     * @param filePath Path to the 3D model file to load.
     * @param flags Importer behavior flags.
     *
     * @return Loaded model structure containing meshes and materials.
     */
    LoadModelEx :: proc(filePath: cstring, flags: ImportFlags) -> Model ---

    /**
     * @brief Load a 3D model from memory buffer.
     *
     * Loads a 3D model from a memory buffer containing the file data.
     * Useful for loading models from embedded resources or network streams.
     *
     * @param data Pointer to the memory buffer containing the model data.
     * @param size Size of the data buffer in bytes.
     * @param hint Hint on the model format (can be NULL).
     *
     * @return Loaded model structure containing meshes and materials.
     *
     * @note External dependencies (e.g., textures or linked resources) are not supported.
     *       The model data must be fully self-contained. Use embedded formats like .glb to ensure compatibility.
     */
    LoadModelFromMemory :: proc(data: rawptr, size: u32, hint: cstring) -> Model ---

    /**
     * @brief Load a 3D model from a memory buffer with import flags.
     *
     * Extended version of R3D_LoadModelFromMemory() allowing control over
     * the import process through additional flags.
     *
     * @param data Pointer to the memory buffer containing the model data.
     * @param size Size of the data buffer in bytes.
     * @param hint Hint on the model format (can be NULL).
     * @param flags Importer behavior flags.
     *
     * @return Loaded model structure containing meshes and materials.
     *
     * @note External dependencies (e.g., textures or linked resources) are not supported.
     *       The model data must be fully self-contained.
     */
    LoadModelFromMemoryEx :: proc(data: rawptr, size: u32, hint: cstring, flags: ImportFlags) -> Model ---

    /**
     * @brief Load a 3D model from an existing importer.
     *
     * Creates a model from a previously loaded importer instance.
     * This avoids re-importing the source file.
     *
     * @param importer Importer instance to extract the model from.
     *
     * @return Loaded model structure containing meshes and materials.
     */
    LoadModelFromImporter :: proc(importer: ^Importer) -> Model ---

    /**
     * @brief Unload a model and optionally its materials.
     *
     * Frees all memory associated with a model, including its meshes.
     * Materials can be optionally unloaded as well.
     *
     * @param model The model to be unloaded.
     * @param unloadMaterials If true, also unloads all materials associated with the model.
     * Set to false if textures are still being used elsewhere to avoid freeing shared resources.
     */
    UnloadModel :: proc(model: Model, unloadMaterials: bool) ---
}

