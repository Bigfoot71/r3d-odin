/* r3d_instance.odin -- R3D Instance Module.
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
 * @brief GPU buffers storing instance attribute streams.
 *
 * buffers: One VBO per attribute (indexed by flag order).
 * capcity: Maximum number of instances.
 * flags: Enabled attribute mask.
 */
InstanceBuffer :: struct {
    buffers:  [5]u32,
    flags:    InstanceFlags,
    capacity: i32,
}

@(default_calling_convention="c", link_prefix="R3D_")
foreign lib {
    /**
     * @brief Create instance buffers on the GPU.
     * @param capacity Max instances.
     * @param flags Attribute mask to allocate.
     * @return Initialized instance buffer.
     */
    LoadInstanceBuffer :: proc(capacity: i32, flags: InstanceFlags) -> InstanceBuffer ---

    /**
     * @brief Destroy all GPU buffers owned by this instance buffer.
     */
    UnloadInstanceBuffer :: proc(buffer: InstanceBuffer) ---

    /**
     * @brief Upload a contiguous range of instance data.
     * @param flag Attribute being updated (single bit).
     * @param offset First instance index.
     * @param count Number of instances.
     * @param data Source pointer.
     */
    UploadInstances :: proc(buffer: InstanceBuffer, flag: InstanceFlags, offset: i32, count: i32, data: rawptr) ---

    /**
     * @brief Map an attribute buffer for CPU write access.
     * @param flag Attribute to map (single bit).
     * @return Writable pointer, or NULL on error.
     */
    MapInstances :: proc(buffer: InstanceBuffer, flag: InstanceFlags) -> rawptr ---

    /**
     * @brief Unmap one or more previously mapped attribute buffers.
     * @param flags Bitmask of attributes to unmap.
     */
    UnmapInstances :: proc(buffer: InstanceBuffer, flags: InstanceFlags) ---
}

/**
 * @brief Bitmask defining which instance attributes are present.
 */
InstanceFlag :: enum u32 {
    POSITION = 0,   ///< rl.Vector3
    ROTATION = 1,   ///< rl.Quaternion
    SCALE    = 2,   ///< rl.Vector3
    COLOR    = 3,   ///< rl.Color
    CUSTOM   = 4,   ///< rl.Vector4
}

InstanceFlags :: bit_set[InstanceFlag; u32]
