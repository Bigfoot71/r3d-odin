/* r3d_visibility.odin -- R3D Visibility Module.
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
     * @brief Checks if a point is inside the view frustum.
     *
     * Tests whether a 3D point lies within the camera's frustum by checking against all six planes.
     * You can call this only after `R3D_Begin`, which updates the internal frustum state.
     *
     * @param position The 3D point to test.
     * @return `true` if inside the frustum, `false` otherwise.
     */
    IsPointVisible :: proc(position: rl.Vector3) -> bool ---

    /**
     * @brief Checks if a sphere is inside the view frustum.
     *
     * Tests whether a sphere intersects the camera's frustum using plane-sphere tests.
     * You can call this only after `R3D_Begin`, which updates the internal frustum state.
     *
     * @param position The center of the sphere.
     * @param radius The sphere's radius (must be positive).
     * @return `true` if at least partially inside the frustum, `false` otherwise.
     */
    IsSphereVisible :: proc(position: rl.Vector3, radius: f32) -> bool ---

    /**
     * @brief Checks if an AABB is inside the view frustum.
     *
     * Determines whether an axis-aligned bounding box intersects the frustum.
     * You can call this only after `R3D_Begin`, which updates the internal frustum state.
     *
     * @param aabb The bounding box to test.
     * @return `true` if at least partially inside the frustum, `false` otherwise.
     */
    IsBoundingBoxVisible :: proc(aabb: rl.BoundingBox) -> bool ---

    /**
     * @brief Checks if an OBB is inside the view frustum.
     *
     * Tests an oriented bounding box (transformed AABB) for frustum intersection.
     * You can call this only after `R3D_Begin`, which updates the internal frustum state.
     *
     * @param aabb Local-space bounding box.
     * @param transform World-space transform matrix.
     * @return `true` if the transformed box intersects the frustum, `false` otherwise.
     */
    IsOrientedBoxVisible :: proc(aabb: rl.BoundingBox, transform: rl.Matrix) -> bool ---
}

