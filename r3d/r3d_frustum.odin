/* r3d_frustum.odin -- R3D Frustum Module.
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
 * @brief Frustum plane indices.
 */
FrustumPlane :: enum u32 {
    BACK   = 0,
    FRONT  = 1,
    BOTTOM = 2,
    TOP    = 3,
    RIGHT  = 4,
    LEFT   = 5,
    COUNT  = 6,
}

/**
 * @brief View frustum defined by its clipping planes.
 *
 * Planes are stored as rl.Vector4 (xyz = normal, w = distance).
 */
Frustum :: struct {
    planes: [6]rl.Vector4,
}

@(default_calling_convention="c", link_prefix="R3D_")
foreign lib {
    /**
     * @brief Get the current frustum.
     *
     * Returns the frustum computed during the last call to R3D_Begin().
     */
    GetFrustum :: proc() -> Frustum ---

    /**
     * @brief Compute a frustum from a view-projection matrix.
     */
    ComputeFrustum :: proc(viewProj: rl.Matrix) -> Frustum ---

    /**
     * @brief Compute the axis-aligned bounding box of a frustum.
     *
     * @param invViewProj Inverse view-projection matrix.
     */
    ComputeFrustumBoundingBox :: proc(invViewProj: rl.Matrix) -> rl.BoundingBox ---

    /**
     * @brief Compute the eight corner points of a frustum.
     *
     * @param invViewProj Inverse view-projection matrix.
     * @param corners Output array of 8 points.
     */
    ComputeFrustumCorners :: proc(invViewProj: rl.Matrix, corners: ^[8]rl.Vector3) ---

    /**
     * @brief Check if a point is inside the frustum.
     *
     * @param frustum Frustum to test against. Must not be NULL.
     */
    FrustumContainsPoint :: proc(frustum: ^Frustum, position: rl.Vector3) -> bool ---

    /**
     * @brief Check if any point from a set is inside the frustum.
     *
     * @param frustum Frustum to test against. Must not be NULL.
     */
    FrustumContainsAnyPoint :: proc(frustum: ^Frustum, positions: ^rl.Vector3, count: i32) -> bool ---

    /**
     * @brief Check if a sphere intersects the frustum.
     *
     * @param frustum Frustum to test against. Must not be NULL.
     */
    FrustumIntersectsSphere :: proc(frustum: ^Frustum, position: rl.Vector3, radius: f32) -> bool ---

    /**
     * @brief Check if a bounding box intersects the frustum.
     *
     * @param frustum Frustum to test against. Must not be NULL.
     */
    FrustumIntersectsBoundingBox :: proc(frustum: ^Frustum, aabb: rl.BoundingBox) -> bool ---

    /**
     * @brief Check if an oriented box intersects the frustum.
     *
     * @param frustum Frustum to test against. Must not be NULL.
     */
    FrustumIntersectsOrientedBox :: proc(frustum: ^Frustum, obb: OrientedBox) -> bool ---
}

