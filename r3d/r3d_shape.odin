/* r3d_shape.odin -- R3D Shape Module.
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
 * @brief Oriented bounding box (OBB).
 *
 * Defined by a center point, three orthogonal axes, and half-extents along each axis.
 */
OrientedBox :: struct {
    center:      rl.Vector3,
    axisX:       rl.Vector3,
    axisY:       rl.Vector3,
    axisZ:       rl.Vector3,
    halfExtents: rl.Vector3,
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

@(default_calling_convention="c", link_prefix="R3D_")
foreign lib {
    /**
     * @brief Compute an axis-aligned bounding box from a center and half-extents.
     */
    GetBoundingBox :: proc(center: rl.Vector3, halfExtents: rl.Vector3) -> rl.BoundingBox ---

    /**
     * @brief Compute an oriented bounding box from an AABB and transform.
     */
    GetOrientedBox :: proc(aabb: rl.BoundingBox, transform: rl.Matrix) -> OrientedBox ---

    /**
     * @brief Check if two axis-aligned bounding boxes intersect
     * @param box1 First bounding box
     * @param box2 Second bounding box
     * @return true if collision detected
     */
    CheckCollisionBoundingBoxes :: proc(box1: rl.BoundingBox, box2: rl.BoundingBox) -> bool ---

    /**
     * @brief Check if an axis-aligned bounding box intersects a sphere
     * @param box Bounding box
     * @param center Sphere center
     * @param radius Sphere radius
     * @return true if collision detected
     */
    CheckCollisionBoundingBoxSphere :: proc(box: rl.BoundingBox, center: rl.Vector3, radius: f32) -> bool ---

    /**
     * @brief Check if two oriented bounding boxes intersect
     * @param box1 First oriented box
     * @param box2 Second oriented box
     * @return true if collision detected
     */
    CheckCollisionOrientedBoxes :: proc(box1: OrientedBox, box2: OrientedBox) -> bool ---

    /**
     * @brief Check if an oriented bounding box intersects a sphere
     * @param box Oriented bounding box
     * @param center Sphere center
     * @param radius Sphere radius
     * @return true if collision detected
     */
    CheckCollisionOrientedBoxSphere :: proc(box: OrientedBox, center: rl.Vector3, radius: f32) -> bool ---

    /**
     * @brief Check if two spheres intersect
     * @param center1 First sphere center
     * @param radius1 First sphere radius
     * @param center2 Second sphere center
     * @param radius2 Second sphere radius
     * @return true if collision detected
     */
    CheckCollisionSpheres :: proc(center1: rl.Vector3, radius1: f32, center2: rl.Vector3, radius2: f32) -> bool ---

    /**
     * @brief Check if capsule intersects with bounding box
     * @param capsule Capsule shape
     * @param box Bounding box
     * @return true if collision detected
     */
    CheckCollisionCapsuleBoundingBox :: proc(capsule: Capsule, box: rl.BoundingBox) -> bool ---

    /**
     * @brief Check if capsule intersects with oriented box
     * @param capsule Capsule shape
     * @param box Oriented box
     * @return true if collision detected
     */
    CheckCollisionCapsuleOrientedBox :: proc(capsule: Capsule, box: OrientedBox) -> bool ---

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
     * @brief Check penetration between two axis-aligned bounding boxes
     * @param box1 First bounding box
     * @param box2 Second bounding box
     * @return Penetration information
     */
    CheckPenetrationBoundingBoxes :: proc(box1: rl.BoundingBox, box2: rl.BoundingBox) -> Penetration ---

    /**
     * @brief Check penetration between an axis-aligned bounding box and a sphere
     * @param box Bounding box
     * @param center Sphere center
     * @param radius Sphere radius
     * @return Penetration information
     */
    CheckPenetrationBoundingBoxSphere :: proc(box: rl.BoundingBox, center: rl.Vector3, radius: f32) -> Penetration ---

    /**
     * @brief Check penetration between two oriented bounding boxes
     * @param box1 First oriented box
     * @param box2 Second oriented box
     * @return Penetration information
     */
    CheckPenetrationOrientedBoxes :: proc(box1: OrientedBox, box2: OrientedBox) -> Penetration ---

    /**
     * @brief Check penetration between an oriented bounding box and a sphere
     * @param box Oriented bounding box
     * @param center Sphere center
     * @param radius Sphere radius
     * @return Penetration information
     */
    CheckPenetrationOrientedBoxSphere :: proc(box: OrientedBox, center: rl.Vector3, radius: f32) -> Penetration ---

    /**
     * @brief Check penetration between two spheres
     * @param center1 First sphere center
     * @param radius1 First sphere radius
     * @param center2 Second sphere center
     * @param radius2 Second sphere radius
     * @return Penetration information
     */
    CheckPenetrationSpheres :: proc(center1: rl.Vector3, radius1: f32, center2: rl.Vector3, radius2: f32) -> Penetration ---

    /**
     * @brief Check penetration between a capsule and a bounding box
     * @param capsule Capsule shape
     * @param box Bounding box
     * @return Penetration information
     */
    CheckPenetrationCapsuleBoundingBox :: proc(capsule: Capsule, box: rl.BoundingBox) -> Penetration ---

    /**
     * @brief Check penetration between a capsule and an oriented bounding box
     * @param capsule Capsule shape
     * @param box Oriented bounding box
     * @return Penetration information
     */
    CheckPenetrationCapsuleOrientedBox :: proc(capsule: Capsule, box: OrientedBox) -> Penetration ---

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
     * @brief Cast a ray against a triangle
     * @param ray rl.Ray to cast
     * @param p1 First triangle vertex
     * @param p2 Second triangle vertex
     * @param p3 Third triangle vertex
     * @return rl.Ray collision info (hit, distance, point, normal)
     */
    RaycastTriangle :: proc(ray: rl.Ray, p1: rl.Vector3, p2: rl.Vector3, p3: rl.Vector3) -> rl.RayCollision ---

    /**
     * @brief Cast a ray against a quad
     * @param ray rl.Ray to cast
     * @param p1 First quad vertex
     * @param p2 Second quad vertex
     * @param p3 Third quad vertex
     * @param p4 Fourth quad vertex
     * @note The quad must be strictly planar and non-self-intersecting
     * @return rl.Ray collision info (hit, distance, point, normal)
     */
    RaycastQuad :: proc(ray: rl.Ray, p1: rl.Vector3, p2: rl.Vector3, p3: rl.Vector3, p4: rl.Vector3) -> rl.RayCollision ---

    /**
     * @brief Cast a ray against an axis-aligned bounding box
     * @param ray rl.Ray to cast
     * @param box Bounding box to test against
     * @return rl.Ray collision info (hit, distance, point, normal)
     */
    RaycastBoundingBox :: proc(ray: rl.Ray, box: rl.BoundingBox) -> rl.RayCollision ---

    /**
     * @brief Cast a ray against an oriented bounding box
     * @param ray rl.Ray to cast
     * @param box Oriented bounding box to test against
     * @return rl.Ray collision info (hit, distance, point, normal)
     */
    RaycastOrientedBox :: proc(ray: rl.Ray, box: OrientedBox) -> rl.RayCollision ---

    /**
     * @brief Cast a ray against a sphere
     * @param ray rl.Ray to cast
     * @param center Sphere center
     * @param radius Sphere radius
     * @return rl.Ray collision info (hit, distance, point, normal)
     */
    RaycastSphere :: proc(ray: rl.Ray, center: rl.Vector3, radius: f32) -> rl.RayCollision ---

    /**
     * @brief Cast a ray against a capsule
     * @param ray rl.Ray to cast
     * @param capsule Capsule shape to test against
     * @return rl.Ray collision info (hit, distance, point, normal)
     */
    RaycastCapsule :: proc(ray: rl.Ray, capsule: Capsule) -> rl.RayCollision ---

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

