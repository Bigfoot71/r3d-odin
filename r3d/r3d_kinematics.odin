/* r3d_kinematics.odin -- R3D Kinematics Module.
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
 * @brief Collision information from a sweep test
 */
SweepCollision :: struct {
    point:  rl.Vector3, ///< World space collision point
    normal: rl.Vector3, ///< Surface normal at collision point
    time:   f32,     ///< Time of impact [0-1], fraction along velocity vector
    hit:    bool,    ///< Whether a collision occurred
}

@(default_calling_convention="c", link_prefix="R3D_")
foreign lib {
    /**
     * @brief Remove the normal component from a velocity vector (project onto a plane)
     * @param velocity Incoming velocity
     * @param normal Surface normal (must be normalized)
     * @return Velocity with the component along normal removed
     */
    ClipVelocity :: proc(velocity: rl.Vector3, normal: rl.Vector3) -> rl.Vector3 ---

    /**
     * @brief Reflect a velocity vector off a surface
     * @param velocity Incoming velocity
     * @param normal Surface normal (must be normalized)
     * @param bounciness Coefficient of restitution (0=no bounce, 1=perfect bounce)
     * @return Reflected velocity scaled by bounciness
     */
    ReflectVelocity :: proc(velocity: rl.Vector3, normal: rl.Vector3, bounciness: f32) -> rl.Vector3 ---

    /**
     * @brief Resolve a velocity vector against a sweep collision, sliding along the hit surface
     * @param velocity Desired movement vector
     * @param collision Sweep collision result to resolve against
     * @param outNormal Optional: receives the collision normal if a hit occurred
     * @return Resolved velocity (safe movement + clipped remainder)
     */
    SlideVelocity :: proc(velocity: rl.Vector3, collision: SweepCollision, outNormal: ^rl.Vector3) -> rl.Vector3 ---

    /**
     * @brief Slide sphere along bounding box surface, resolving collisions
     * @param center Sphere center position
     * @param radius Sphere radius
     * @param velocity Desired movement vector
     * @param box Obstacle bounding box
     * @param outNormal Optional: receives collision normal if collision occurred
     * @return Actual movement applied (may be reduced/redirected by collision)
     */
    SlideSphereBoundingBox :: proc(center: rl.Vector3, radius: f32, velocity: rl.Vector3, box: rl.BoundingBox, outNormal: ^rl.Vector3) -> rl.Vector3 ---

    /**
     * @brief Slide sphere along mesh surface, resolving collisions
     * @param center Sphere center position
     * @param radius Sphere radius
     * @param velocity Desired movement vector
     * @param mesh Mesh data to collide against
     * @param transform Mesh world transform
     * @param outNormal Optional: receives collision normal if collision occurred
     * @return Actual movement applied (may be reduced/redirected by collision)
     */
    SlideSphereMesh :: proc(center: rl.Vector3, radius: f32, velocity: rl.Vector3, mesh: MeshData, transform: rl.Matrix, outNormal: ^rl.Vector3) -> rl.Vector3 ---

    /**
     * @brief Slide capsule along bounding box surface, resolving collisions
     * @param capsule Capsule shape
     * @param velocity Desired movement vector
     * @param box Obstacle bounding box
     * @param outNormal Optional: receives collision normal if collision occurred
     * @return Actual movement applied (may be reduced/redirected by collision)
     */
    SlideCapsuleBoundingBox :: proc(capsule: Capsule, velocity: rl.Vector3, box: rl.BoundingBox, outNormal: ^rl.Vector3) -> rl.Vector3 ---

    /**
     * @brief Slide capsule along mesh surface, resolving collisions
     * @param capsule Capsule shape
     * @param velocity Desired movement vector
     * @param mesh Mesh data to collide against
     * @param transform Mesh world transform
     * @param outNormal Optional: receives collision normal if collision occurred
     * @return Actual movement applied (may be reduced/redirected by collision)
     */
    SlideCapsuleMesh :: proc(capsule: Capsule, velocity: rl.Vector3, mesh: MeshData, transform: rl.Matrix, outNormal: ^rl.Vector3) -> rl.Vector3 ---

    /**
     * @brief Push sphere out of bounding box if penetrating
     * @param center Sphere center (modified in place if penetrating)
     * @param radius Sphere radius
     * @param box Obstacle box
     * @param outPenetration Optional: receives penetration depth
     * @return true if depenetration occurred
     */
    DepenetrateSphereBoundingBox :: proc(center: ^rl.Vector3, radius: f32, box: rl.BoundingBox, outPenetration: ^f32) -> bool ---

    /**
     * @brief Push capsule out of bounding box if penetrating
     * @param capsule Capsule shape (modified in place if penetrating)
     * @param box Obstacle box
     * @param outPenetration Optional: receives penetration depth
     * @return true if depenetration occurred
     */
    DepenetrateCapsuleBoundingBox :: proc(capsule: ^Capsule, box: rl.BoundingBox, outPenetration: ^f32) -> bool ---

    /**
     * @brief Check if a sphere is supported by a bounding box in a given direction
     * @param center Sphere center
     * @param radius Sphere radius
     * @param direction rl.Ray direction to probe (must be normalized)
     * @param distance Maximum probe distance beyond the sphere surface
     * @param box Bounding box to test against
     * @param outHit Optional: receives raycast hit info
     * @return true if a surface is within reach in the given direction
     */
    CheckSphereSupportBoundingBox :: proc(center: rl.Vector3, radius: f32, direction: rl.Vector3, distance: f32, box: rl.BoundingBox, outHit: ^rl.RayCollision) -> bool ---

    /**
     * @brief Check if a sphere is supported by mesh geometry in a given direction
     * @param center Sphere center
     * @param radius Sphere radius
     * @param direction rl.Ray direction to probe (must be normalized)
     * @param distance Maximum probe distance beyond the sphere surface
     * @param mesh Mesh data to test against
     * @param transform Mesh world transform
     * @param outHit Optional: receives raycast hit info
     * @return true if a surface is within reach in the given direction
     */
    CheckSphereSupportMesh :: proc(center: rl.Vector3, radius: f32, direction: rl.Vector3, distance: f32, mesh: MeshData, transform: rl.Matrix, outHit: ^rl.RayCollision) -> bool ---

    /**
     * @brief Check if a capsule is supported by a bounding box in a given direction
     * @param capsule Capsule shape
     * @param direction rl.Ray direction to probe (must be normalized)
     * @param distance Maximum probe distance beyond the capsule surface
     * @param box Bounding box to test against
     * @param outHit Optional: receives raycast hit info
     * @return true if a surface is within reach in the given direction
     */
    CheckCapsuleSupportBoundingBox :: proc(capsule: Capsule, direction: rl.Vector3, distance: f32, box: rl.BoundingBox, outHit: ^rl.RayCollision) -> bool ---

    /**
     * @brief Check if a capsule is supported by mesh geometry in a given direction
     * @param capsule Capsule shape
     * @param direction rl.Ray direction to probe (must be normalized)
     * @param distance Maximum probe distance beyond the capsule surface
     * @param mesh Mesh data to test against
     * @param transform Mesh world transform
     * @param outHit Optional: receives raycast hit info
     * @return true if a surface is within reach in the given direction
     */
    CheckCapsuleSupportMesh :: proc(capsule: Capsule, direction: rl.Vector3, distance: f32, mesh: MeshData, transform: rl.Matrix, outHit: ^rl.RayCollision) -> bool ---

    /**
     * @brief Sweep sphere against single point
     * @param center Sphere center position
     * @param radius Sphere radius
     * @param velocity Movement vector (direction and magnitude)
     * @param point Point to test against
     * @return Sweep collision info (hit, time, point, normal)
     */
    SweepSpherePoint :: proc(center: rl.Vector3, radius: f32, velocity: rl.Vector3, point: rl.Vector3) -> SweepCollision ---

    /**
     * @brief Sweep sphere against line segment
     * @param center Sphere center position
     * @param radius Sphere radius
     * @param velocity Movement vector (direction and magnitude)
     * @param a Segment start point
     * @param b Segment end point
     * @return Sweep collision info (hit, time, point, normal)
     */
    SweepSphereSegment :: proc(center: rl.Vector3, radius: f32, velocity: rl.Vector3, a: rl.Vector3, b: rl.Vector3) -> SweepCollision ---

    /**
     * @brief Sweep sphere against triangle plane (no edge/vertex clipping)
     * @param center Sphere center position
     * @param radius Sphere radius
     * @param velocity Movement vector (direction and magnitude)
     * @param a Triangle vertex A
     * @param b Triangle vertex B
     * @param c Triangle vertex C
     * @return Sweep collision info (hit, time, point, normal)
     */
    SweepSphereTrianglePlane :: proc(center: rl.Vector3, radius: f32, velocity: rl.Vector3, a: rl.Vector3, b: rl.Vector3, _c: rl.Vector3) -> SweepCollision ---

    /**
     * @brief Sweep sphere against triangle with edge/vertex handling
     * @param center Sphere center position
     * @param radius Sphere radius
     * @param velocity Movement vector (direction and magnitude)
     * @param a Triangle vertex A
     * @param b Triangle vertex B
     * @param c Triangle vertex C
     * @return Sweep collision info (hit, time, point, normal)
     */
    SweepSphereTriangle :: proc(center: rl.Vector3, radius: f32, velocity: rl.Vector3, a: rl.Vector3, b: rl.Vector3, _c: rl.Vector3) -> SweepCollision ---

    /**
     * @brief Sweep sphere along velocity vector
     * @param center Sphere center position
     * @param radius Sphere radius
     * @param velocity Movement vector (direction and magnitude)
     * @param box Obstacle bounding box
     * @return Sweep collision info (hit, distance, point, normal)
     */
    SweepSphereBoundingBox :: proc(center: rl.Vector3, radius: f32, velocity: rl.Vector3, box: rl.BoundingBox) -> SweepCollision ---

    /**
     * @brief Sweep sphere along velocity vector against mesh geometry
     * @param center Sphere center position
     * @param radius Sphere radius
     * @param velocity Movement vector (direction and magnitude)
     * @param mesh Mesh data to test against
     * @param transform Mesh world transform
     * @return Sweep collision info (hit, time, point, normal)
     */
    SweepSphereMesh :: proc(center: rl.Vector3, radius: f32, velocity: rl.Vector3, mesh: MeshData, transform: rl.Matrix) -> SweepCollision ---

    /**
     * @brief Sweep capsule along velocity vector
     * @param capsule Capsule shape to sweep
     * @param velocity Movement vector (direction and magnitude)
     * @param box Obstacle bounding box
     * @return Sweep collision info (hit, distance, point, normal)
     */
    SweepCapsuleBoundingBox :: proc(capsule: Capsule, velocity: rl.Vector3, box: rl.BoundingBox) -> SweepCollision ---

    /**
     * @brief Sweep capsule along velocity vector against mesh geometry
     * @param capsule Capsule shape to sweep
     * @param velocity Movement vector (direction and magnitude)
     * @param mesh Mesh data to test against
     * @param transform Mesh world transform
     * @return Sweep collision info (hit, time, point, normal)
     */
    SweepCapsuleMesh :: proc(capsule: Capsule, velocity: rl.Vector3, mesh: MeshData, transform: rl.Matrix) -> SweepCollision ---
}

