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
 * @brief Storage format used by an instance attribute.
 *
 * The selected format controls how the attribute is stored in GPU memory.
 * All formats are read by the shader as floating-point values.
 *
 * UNORM formats are converted to the [0, 1] range.
 * SNORM formats are converted to the [-1, 1] range.
 */
InstanceFormat :: enum u32 {
    FLOAT32 = 0, ///< 32-bit floating-point component.
    FLOAT16 = 1, ///< 16-bit floating-point component.
    UNORM16 = 2, ///< 16-bit unsigned normalized component.
    SNORM16 = 3, ///< 16-bit signed normalized component.
    UNORM8  = 4, ///< 8-bit unsigned normalized component.
    SNORM8  = 5, ///< 8-bit signed normalized component.
    COUNT   = 6, ///< Number of available instance formats.
}

/**
 * @brief Describes the layout of an instance buffer.
 *
 * `flags` defines which instance attributes are allocated.
 * `formats` defines the storage format used by each attribute.
 *
 * The `formats` array is indexed in the same order as the instance attribute
 * flags:
 *
 * - index 0: `R3D_INSTANCE_POSITION`
 * - index 1: `R3D_INSTANCE_ROTATION`
 * - index 2: `R3D_INSTANCE_SCALE`
 * - index 3: `R3D_INSTANCE_COLOR`
 * - index 4: `R3D_INSTANCE_CUSTOM`
 *
 * Data uploaded or mapped for an attribute must match the format selected for
 * that attribute.
 */
InstanceLayout :: struct {
    formats: [5]InstanceFormat, ///< Storage format for each instance attribute.
    flags:   InstanceFlags,     ///< Enabled instance attribute mask.
}

/**
 * @brief GPU buffers storing instance attribute streams.
 *
 * Each enabled attribute owns one GPU buffer. The enabled attributes and their
 * storage formats are described by `layout`.
 */
InstanceBuffer :: struct {
    buffers:  [5]u32,         ///< One GPU buffer per attribute, indexed by attribute order.
    layout:   InstanceLayout, ///< Instance buffer layout.
    capacity: i32,            ///< Maximum number of instances.
}

@(default_calling_convention="c", link_prefix="R3D_")
foreign lib {
    /**
     * @brief Creates instance buffers on the GPU using the default layout.
     *
     * This is the simple entry point. It allocates one GPU buffer for each enabled
     * attribute in `flags`.
     *
     * Default formats:
     *
     * - position: FLOAT32
     * - rotation: FLOAT32
     * - scale:    FLOAT32
     * - color:    UNORM8
     * - custom:   FLOAT32
     *
     * @param capacity Maximum number of instances.
     * @param flags    Attribute mask to allocate.
     *
     * @return Initialized instance buffer, or an empty buffer on failure.
     */
    LoadInstanceBuffer :: proc(capacity: i32, flags: InstanceFlags) -> InstanceBuffer ---

    /**
     * @brief Creates instance buffers on the GPU using a custom layout.
     *
     * This is the advanced entry point. It allocates one GPU buffer for each
     * enabled attribute in `layout.flags`, using the corresponding storage format
     * from `layout.formats`.
     *
     * Data uploaded or mapped for each attribute must match the format selected in
     * the layout.
     *
     * @param capacity Maximum number of instances.
     * @param layout   Instance layout describing enabled attributes and formats.
     *
     * @return Initialized instance buffer, or an empty buffer on failure.
     */
    LoadInstanceBufferEx :: proc(capacity: i32, layout: InstanceLayout) -> InstanceBuffer ---

    /**
     * @brief Destroy all GPU buffers owned by this instance buffer.
     */
    UnloadInstanceBuffer :: proc(buffer: InstanceBuffer) ---

    /**
     * @brief Grow the GPU buffers of an instance buffer to a new capacity.
     *
     * Only expands; if newCapacity <= buffer->capacity the call is a no-op.
     * All attribute buffers present in buffer->flags are reallocated and
     * if keepData is true, their existing content is copied to the new
     * buffers before the old ones are deleted.
     *
     * @param buffer      Instance buffer to resize (updated in place).
     * @param newCapacity Desired minimum capacity in number of instances.
     * @param keepData    If true, preserves existing instance data.
     */
    ResizeInstanceBuffer :: proc(buffer: ^InstanceBuffer, newCapacity: i32, keepData: bool) ---

    /**
     * @brief Upload a contiguous range of instance data to a GPU buffer.
     *
     * @param buffer  Instance buffer containing the target GPU buffer.
     * @param flag    Attribute to update (single bit).
     * @param offset  First instance index.
     * @param count   Number of instances to upload.
     * @param data    Source data pointer.
     * @param discard If true, the entire GPU buffer is orphaned before upload,
     *                avoiding a GPU/CPU sync at the cost of discarding existing data.
     *                Safe to use when rewriting the full buffer each frame.
     */
    UploadInstances :: proc(buffer: InstanceBuffer, flag: InstanceFlags, offset: i32, count: i32, data: rawptr, discard: bool) ---

    /**
     * @brief Map an entire attribute buffer for CPU write access.
     *
     * Call R3D_UnmapInstances when done writing.
     *
     * @param buffer  Instance buffer containing the target GPU buffer.
     * @param flag    Attribute to map (single bit).
     * @param discard If true, existing buffer contents are invalidated,
     *                allowing the driver to return a fresh memory region
     *                without stalling on in-flight GPU reads.
     * @return        Writable pointer to the full buffer, or NULL on error.
     */
    MapInstances :: proc(buffer: InstanceBuffer, flag: InstanceFlags, discard: bool) -> rawptr ---

    /**
     * @brief Map a sub-range of an attribute buffer for CPU write access.
     *
     * Prefer this over R3D_MapInstances for partial updates to avoid
     * touching unrelated data. Call R3D_UnmapInstances when done writing.
     *
     * @param buffer  Instance buffer containing the target GPU buffer.
     * @param flag    Attribute to map (single bit).
     * @param offset  First instance index of the mapped range.
     * @param count   Number of instances to map.
     * @param discard If true, the mapped range is invalidated, allowing the
     *                driver to skip syncing that region with in-flight GPU reads.
     * @return        Writable pointer to the mapped range, or NULL on error.
     */
    MapInstancesEx :: proc(buffer: InstanceBuffer, flag: InstanceFlags, offset: i32, count: i32, discard: bool) -> rawptr ---

    /**
     * @brief Unmap one or more previously mapped attribute buffers.
     * @param flags Bitmask of attributes to unmap.
     */
    UnmapInstances :: proc(buffer: InstanceBuffer, flags: InstanceFlags) ---

    /**
     * @brief Sets the storage format of an instance attribute in a layout.
     *
     * `attribute` must be a single instance attribute flag, such as
     * `R3D_INSTANCE_POSITION`, not a combination of multiple flags.
     *
     * This function only changes the format stored in the layout. It does not
     * enable the attribute in `layout.flags`.
     *
     * @param layout    Layout to modify.
     * @param attribute Single attribute flag to modify.
     * @param format    New storage format.
     */
    SetInstanceFormat :: proc(layout: ^InstanceLayout, attribute: InstanceFlags, format: InstanceFormat) ---

    /**
     * @brief Gets the storage format of an instance attribute from a layout.
     *
     * `attribute` must be a single instance attribute flag, such as
     * `R3D_INSTANCE_POSITION`, not a combination of multiple flags.
     *
     * @param layout    Layout to read from.
     * @param attribute Single attribute flag to query.
     *
     * @return Storage format of the requested attribute, or FLOAT32 if the
     * attribute flag is invalid.
     */
    GetInstanceFormat :: proc(layout: InstanceLayout, attribute: InstanceFlags) -> InstanceFormat ---
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
