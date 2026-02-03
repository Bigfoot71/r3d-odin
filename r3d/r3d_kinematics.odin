/* r3d_kinematics.odin -- R3D Kinematics Module.
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
 * @brief Capsule shape defined by two endpoints and radius
 */
Capsule :: struct {
    start:  rl.Vector3, ///< Start point of capsule axis
    end:    rl.Vector3, ///< End point of capsule axis
    radius: f32,     ///< Capsule radius
}

/**
 * @brief Penetration information from an overlap test
 */
Penetration :: struct {
    collides: bool,    ///< Whether shapes are overlapping
    depth:    f32,     ///< Penetration depth
    normal:   rl.Vector3, ///< Collision normal (direction to resolve penetration)
    mtv:      rl.Vector3, ///< Minimum Translation Vector (normal * depth)
}

/**
 * @brief Collision information from a sweep test
 */
SweepCollision :: struct {
    hit:    bool,    ///< Whether a collision occurred
    time:   f32,     ///< Time of impact [0-1], fraction along velocity vector
    point:  rl.Vector3, ///< World space collision point
    normal: rl.Vector3, ///< Surface normal at collision point
}

@(default_calling_convention="c", link_prefix="R3D_")
foreign lib {
    /**
     * @brief Check if capsule intersects with box
     * @param capsule Capsule shape
     * @param box Bounding box
     * @return true if collision detected
     */
    CheckCollisionCapsuleBox :: proc(capsule: Capsule, box: rl.BoundingBox) -> bool ---

    /**
     * @brief Check if capsule intersects with sphere
     * @param capsule Capsule shape
     * @param center Sphere center
     * @param radius Sphere radius
     * @return true if collision detected
     */
    CheckCollisionCapsuleSphere :: proc(capsule: Capsule, center: rl.Vector3, radius: f32) -> bool ---

    /**
     * @brief Check if two capsules intersect
     * @param a First capsule
     * @param b Second capsule
     * @return true if collision detected
     */
    CheckCollisionCapsules :: proc(a: Capsule, b: Capsule) -> bool ---

    /**
     * @brief Check if capsule intersects with mesh
     * @param capsule Capsule shape
     * @param mesh Mesh data
     * @param transform Mesh transform
     * @return true if collision detected
     */
    CheckCollisionCapsuleMesh :: proc(capsule: Capsule, mesh: MeshData, transform: rl.Matrix) -> bool ---

    /**
     * @brief Check penetration between capsule and box
     * @param capsule Capsule shape
     * @param box Bounding box
     * @return Penetration information.
     */
    CheckPenetrationCapsuleBox :: proc(capsule: Capsule, box: rl.BoundingBox) -> Penetration ---

    /**
     * @brief Check penetration between capsule and sphere
     * @param capsule Capsule shape
     * @param center Sphere center
     * @param radius Sphere radius
     * @return Penetration information.
     */
    CheckPenetrationCapsuleSphere :: proc(capsule: Capsule, center: rl.Vector3, radius: f32) -> Penetration ---

    /**
     * @brief Check penetration between two capsules
     * @param a First capsule
     * @param b Second capsule
     * @return Penetration information.
     */
    CheckPenetrationCapsules :: proc(a: Capsule, b: Capsule) -> Penetration ---

    /**
     * @brief Calculate slide velocity along surface
     * @param velocity Original velocity
     * @param normal Surface normal (must be normalized)
     * @return Velocity sliding along surface (perpendicular component removed)
     */
    SlideVelocity :: proc(velocity: rl.Vector3, normal: rl.Vector3) -> rl.Vector3 ---

    /**
     * @brief Calculate bounce velocity after collision
     * @param velocity Incoming velocity
     * @param normal Surface normal (must be normalized)
     * @param bounciness Coefficient of restitution (0=no bounce, 1=perfect bounce)
     * @return Reflected velocity
     */
    BounceVelocity :: proc(velocity: rl.Vector3, normal: rl.Vector3, bounciness: f32) -> rl.Vector3 ---

    /**
     * @brief Slide sphere along box surface, resolving collisions
     * @param center Sphere center position
     * @param radius Sphere radius
     * @param velocity Desired movement vector
     * @param box Obstacle bounding box
     * @param outNormal Optional: receives collision normal if collision occurred
     * @return Actual movement applied (may be reduced/redirected by collision)
     */
    SlideSphereBox :: proc(center: rl.Vector3, radius: f32, velocity: rl.Vector3, box: rl.BoundingBox, outNormal: ^rl.Vector3) -> rl.Vector3 ---

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
     * @brief Slide capsule along box surface, resolving collisions
     * @param capsule Capsule shape
     * @param velocity Desired movement vector
     * @param box Obstacle bounding box
     * @param outNormal Optional: receives collision normal if collision occurred
     * @return Actual movement applied (may be reduced/redirected by collision)
     */
    SlideCapsuleBox :: proc(capsule: Capsule, velocity: rl.Vector3, box: rl.BoundingBox, outNormal: ^rl.Vector3) -> rl.Vector3 ---

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
     * @brief Push sphere out of box if penetrating
     * @param center Sphere center (modified in place if penetrating)
     * @param radius Sphere radius
     * @param box Obstacle box
     * @param outPenetration Optional: receives penetration depth
     * @return true if depenetration occurred
     */
    DepenetrateSphereBox :: proc(center: ^rl.Vector3, radius: f32, box: rl.BoundingBox, outPenetration: ^f32) -> bool ---

    /**
     * @brief Push capsule out of box if penetrating
     * @param capsule Capsule shape (modified in place if penetrating)
     * @param box Obstacle box
     * @param outPenetration Optional: receives penetration depth
     * @return true if depenetration occurred
     */
    DepenetrateCapsuleBox :: proc(capsule: ^Capsule, box: rl.BoundingBox, outPenetration: ^f32) -> bool ---

    /**
     * @brief Cast a ray against mesh geometry
     * @param ray rl.Ray to cast
     * @param mesh Mesh data to test against
     * @param transform Mesh world transform
     * @return rl.Ray collision info (hit, distance, point, normal)
     */
    RaycastMesh :: proc(ray: rl.Ray, mesh: MeshData, transform: rl.Matrix) -> rl.RayCollision ---

    /**
     * @brief Cast a ray against a model (tests all meshes)
     * @param ray rl.Ray to cast
     * @param model Model to test against (must have valid meshData)
     * @param transform Model world transform
     * @return rl.Ray collision info for closest hit (hit=false if no meshData)
     */
    RaycastModel :: proc(ray: rl.Ray, model: Model, transform: rl.Matrix) -> rl.RayCollision ---

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
    SweepSphereBox :: proc(center: rl.Vector3, radius: f32, velocity: rl.Vector3, box: rl.BoundingBox) -> SweepCollision ---

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
    SweepCapsuleBox :: proc(capsule: Capsule, velocity: rl.Vector3, box: rl.BoundingBox) -> SweepCollision ---

    /**
     * @brief Sweep capsule along velocity vector against mesh geometry
     * @param capsule Capsule shape to sweep
     * @param velocity Movement vector (direction and magnitude)
     * @param mesh Mesh data to test against
     * @param transform Mesh world transform
     * @return Sweep collision info (hit, time, point, normal)
     */
    SweepCapsuleMesh :: proc(capsule: Capsule, velocity: rl.Vector3, mesh: MeshData, transform: rl.Matrix) -> SweepCollision ---

    /**
     * @brief Check if sphere is grounded against a box
     * @param center Sphere center
     * @param radius Sphere radius
     * @param checkDistance How far below to check
     * @param ground Ground box to test against
     * @param outGround Optional: receives raycast hit info
     * @return true if grounded within checkDistance
     */
    IsSphereGroundedBox :: proc(center: rl.Vector3, radius: f32, checkDistance: f32, ground: rl.BoundingBox, outGround: ^rl.RayCollision) -> bool ---

    /**
     * @brief Check if sphere is grounded against mesh geometry
     * @param center Sphere center
     * @param radius Sphere radius
     * @param checkDistance How far below to check
     * @param mesh Mesh data to test against
     * @param transform Mesh world transform
     * @param outGround Optional: receives raycast hit info
     * @return true if grounded within checkDistance
     */
    IsSphereGroundedMesh :: proc(center: rl.Vector3, radius: f32, checkDistance: f32, mesh: MeshData, transform: rl.Matrix, outGround: ^rl.RayCollision) -> bool ---

    /**
     * @brief Check if capsule is grounded against a box
     * @param capsule Character capsule
     * @param checkDistance How far below to check (e.g., 0.1)
     * @param ground Ground box to test against
     * @param outGround Optional: receives raycast hit info
     * @return true if grounded within checkDistance
     */
    IsCapsuleGroundedBox :: proc(capsule: Capsule, checkDistance: f32, ground: rl.BoundingBox, outGround: ^rl.RayCollision) -> bool ---

    /**
     * @brief Check if capsule is grounded against mesh geometry
     * @param capsule Character capsule
     * @param checkDistance How far below to check
     * @param mesh Mesh data to test against
     * @param transform Mesh world transform
     * @param outGround Optional: receives raycast hit info
     * @return true if grounded within checkDistance
     */
    IsCapsuleGroundedMesh :: proc(capsule: Capsule, checkDistance: f32, mesh: MeshData, transform: rl.Matrix, outGround: ^rl.RayCollision) -> bool ---

    /**
     * @brief Find closest point on line segment to given point
     * @param point Query point
     * @param start Segment start
     * @param end Segment end
     * @return Closest point on segment [start, end]
     */
    ClosestPointOnSegment :: proc(point: rl.Vector3, start: rl.Vector3, end: rl.Vector3) -> rl.Vector3 ---

    /**
     * @brief Find closest point on triangle to given point
     * @param p Query point
     * @param a Triangle vertex A
     * @param b Triangle vertex B
     * @param c Triangle vertex C
     * @return Closest point on triangle surface
     */
    ClosestPointOnTriangle :: proc(p: rl.Vector3, a: rl.Vector3, b: rl.Vector3, _c: rl.Vector3) -> rl.Vector3 ---

    /**
     * @brief Find closest point on box surface to given point
     * @param point Query point
     * @param box Bounding box
     * @return Closest point on/in box (clamped to box bounds)
     */
    ClosestPointOnBox :: proc(point: rl.Vector3, box: rl.BoundingBox) -> rl.Vector3 ---
}

