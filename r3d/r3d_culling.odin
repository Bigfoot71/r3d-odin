/* r3d_culling.odin -- R3D Culling Module.
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

@(default_calling_convention="c", link_prefix="R3D_")
foreign lib {
    /**
     * @brief Checks if a point is inside the view frustum.
     *
     * Tests whether a 3D point lies within the camera's frustum by checking against all six planes.
     * Call this only between `R3D_Begin` and `R3D_End`.
     *
     * Useful when automatic frustum culling is disabled and you're using a custom spatial structure
     * (e.g., octree, BVH, etc.).
     *
     * @param position The 3D point to test.
     * @return `true` if inside the frustum, `false` otherwise.
     *
     * @note This performs an exact plane-point test. Slower than bounding box tests.
     * @warning Frustum culling may incorrectly discard objects casting visible shadows.
     * @todo Improve shadow-aware culling in future versions.
     *
     * @see R3D_IsPointInFrustumBoundingBox()
     */
    IsPointInFrustum :: proc(position: rl.Vector3) -> bool ---

    /**
     * @brief Checks if a sphere is inside the view frustum.
     *
     * Tests whether a sphere intersects the camera's frustum using plane-sphere tests.
     * Call this only between `R3D_Begin` and `R3D_End`.
     *
     * Useful when managing visibility manually.
     *
     * @param position The center of the sphere.
     * @param radius The sphere's radius (must be positive).
     * @return `true` if at least partially inside the frustum, `false` otherwise.
     *
     * @note More accurate but slower than bounding box approximations.
     * @warning May cause visual issues with shadow casters being culled too early.
     * @todo Add support for shadow-aware visibility.
     *
     * @see R3D_IsSphereInFrustumBoundingBox()
     */
    IsSphereInFrustum :: proc(position: rl.Vector3, radius: f32) -> bool ---

    /**
     * @brief Checks if an AABB is inside the view frustum.
     *
     * Determines whether an axis-aligned bounding box intersects the frustum.
     * Call between `R3D_Begin` and `R3D_End`.
     *
     * For use in custom culling strategies or spatial partitioning systems.
     *
     * @param aabb The bounding box to test.
     * @return `true` if at least partially inside the frustum, `false` otherwise.
     *
     * @note Exact but more costly than AABB pre-tests.
     * @warning May prematurely cull objects casting visible shadows.
     * @todo Add support for light-aware visibility tests.
     *
     * @see R3D_IsAABBInFrustumBoundingBox()
     */
    IsAABBInFrustum :: proc(aabb: rl.BoundingBox) -> bool ---

    /**
     * @brief Checks if an OBB is inside the view frustum.
     *
     * Tests an oriented bounding box (transformed AABB) for frustum intersection.
     * Must be called between `R3D_Begin` and `R3D_End`.
     *
     * Use this for objects with transformations when doing manual culling.
     *
     * @param aabb Local-space bounding box.
     * @param transform World-space transform matrix.
     * @return `true` if the transformed box intersects the frustum, `false` otherwise.
     *
     * @note More expensive than AABB checks due to matrix operations.
     * @warning May incorrectly cull shadow casters.
     * @todo Consider shadow-aware culling improvements.
     *
     * @see R3D_IsAABBInFrustum()
     */
    IsOBBInFrustum :: proc(aabb: rl.BoundingBox, transform: rl.Matrix) -> bool ---
}

