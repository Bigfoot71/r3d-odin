/* r3d_mesh.odin -- R3D Mesh Module.
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
 * @brief Hint on how a mesh will be used.
 */
MeshUsage :: enum u32 {
    STATIC_MESH   = 0, ///< Will never be updated.
    DYNAMIC_MESH  = 1, ///< Will be updated occasionally.
    STREAMED_MESH = 2, ///< Will be update on each frame.
}

/**
 * @brief Defines the geometric primitive type.
 */
PrimitiveType :: enum u32 {
    POINTS         = 0, ///< Each vertex represents a single point.
    LINES          = 1, ///< Each pair of vertices forms an independent line segment.
    LINE_STRIP     = 2, ///< Connected series of line segments sharing vertices.
    LINE_LOOP      = 3, ///< Closed loop of connected line segments.
    TRIANGLES      = 4, ///< Each set of three vertices forms an independent triangle.
    TRIANGLE_STRIP = 5, ///< Connected strip of triangles sharing vertices.
    TRIANGLE_FAN   = 6, ///< Fan of triangles sharing the first vertex.
}

/**
 * @brief Shadow casting modes for objects.
 *
 * Controls how an object interacts with the shadow mapping system.
 * These modes determine whether the object contributes to shadows,
 * and if so, whether it is also rendered in the main pass.
 */
ShadowCastMode :: enum u32 {
    ON_AUTO           = 0, ///< The object casts shadows; the faces used are determined by the material's culling mode.
    ON_DOUBLE_SIDED   = 1, ///< The object casts shadows with both front and back faces, ignoring face culling.
    ON_FRONT_SIDE     = 2, ///< The object casts shadows with only front faces, culling back faces.
    ON_BACK_SIDE      = 3, ///< The object casts shadows with only back faces, culling front faces.
    ONLY_AUTO         = 4, ///< The object only casts shadows; the faces used are determined by the material's culling mode.
    ONLY_DOUBLE_SIDED = 5, ///< The object only casts shadows with both front and back faces, ignoring face culling.
    ONLY_FRONT_SIDE   = 6, ///< The object only casts shadows with only front faces, culling back faces.
    ONLY_BACK_SIDE    = 7, ///< The object only casts shadows with only back faces, culling front faces.
    DISABLED          = 8, ///< The object does not cast shadows at all.
}

/**
 * @brief Represents a 3D mesh.
 *
 * Stores vertex and index data, shadow casting settings, bounding box, and layer information.
 * Can represent a static or skinned mesh.
 */
Mesh :: struct {
    vao, vbo, ebo:                     u32,            ///< OpenGL objects handles.
    vertexCount, indexCount:           i32,            ///< Number of vertices and indices currently in use.
    allocVertexCount, allocIndexCount: i32,            ///< Number of vertices and indices allocated in GPU buffers.
    shadowCastMode:                    ShadowCastMode, ///< Shadow casting mode for the mesh.
    primitiveType:                     PrimitiveType,  ///< Type of primitive that constitutes the vertices.
    usage:                             MeshUsage,      ///< Hint about the usage of the mesh, retained in case of update if there is a reallocation.
    layerMask:                         Layer,          ///< Bitfield indicating the rendering layer(s) of this mesh.
    aabb:                              rl.BoundingBox,    ///< Axis-Aligned Bounding Box in local space.
}

@(default_calling_convention="c", link_prefix="R3D_")
foreign lib {
    /**
     * @brief Creates a 3D mesh from CPU-side mesh data.
     * @param type Primitive type used to interpret vertex data.
     * @param data R3D_MeshData containing vertices and indices (cannot be NULL).
     * @param aabb Optional pointer to a bounding box. If NULL, it will be computed automatically.
     * @param usage Hint on how the mesh will be used.
     * @return Created R3D_Mesh.
     * @note The function copies all vertex and index data into GPU buffers.
     */
    LoadMesh :: proc(type: PrimitiveType, data: MeshData, aabb: ^rl.BoundingBox, usage: MeshUsage) -> Mesh ---

    /**
     * @brief Destroys a 3D mesh and frees its resources.
     * @param mesh R3D_Mesh to destroy.
     */
    UnloadMesh :: proc(mesh: Mesh) ---

    /**
     * @brief Check if a mesh is valid for rendering.
     *
     * Returns true if the mesh has a valid VAO and VBO.
     *
     * @param mesh The mesh to check.
     * @return true if valid, false otherwise.
     */
    IsMeshValid :: proc(mesh: Mesh) -> bool ---

    /**
     * @brief Generate a quad mesh with orientation.
     * @param width Width along local X axis.
     * @param length Length along local Z axis.
     * @param resX Subdivisions along width.
     * @param resZ Subdivisions along length.
     * @param frontDir Direction vector for the quad's front face.
     * @return Mesh ready for rendering.
     * @see R3D_GenMeshDataQuad
     */
    GenMeshQuad :: proc(width: f32, length: f32, resX: i32, resZ: i32, frontDir: rl.Vector3) -> Mesh ---

    /**
     * @brief Generate a plane mesh.
     * @param width Width along X axis.
     * @param length Length along Z axis.
     * @param resX Subdivisions along X axis.
     * @param resZ Subdivisions along Z axis.
     * @return Mesh ready for rendering.
     * @see R3D_GenMeshDataPlane
     */
    GenMeshPlane :: proc(width: f32, length: f32, resX: i32, resZ: i32) -> Mesh ---

    /**
     * @brief Generate a polygon mesh.
     * @param sides Number of sides (min 3).
     * @param radius Radius of the polygon.
     * @param frontDir Direction vector for the polygon's front face.
     * @return Mesh ready for rendering.
     * @see R3D_GenMeshDataPoly
     */
    GenMeshPoly :: proc(sides: i32, radius: f32, frontDir: rl.Vector3) -> Mesh ---

    /**
     * @brief Generate a cube mesh.
     * @param width Width along X axis.
     * @param height Height along Y axis.
     * @param length Length along Z axis.
     * @return Mesh ready for rendering.
     * @see R3D_GenMeshDataCube
     */
    GenMeshCube :: proc(width: f32, height: f32, length: f32) -> Mesh ---

    /**
     * @brief Generate a subdivided cube mesh.
     * @param width Width along X axis.
     * @param height Height along Y axis.
     * @param length Length along Z axis.
     * @param resX Subdivisions along X axis.
     * @param resY Subdivisions along Y axis.
     * @param resZ Subdivisions along Z axis.
     * @return Mesh ready for rendering.
     * @see R3D_GenMeshDataCubeEx
     */
    GenMeshCubeEx :: proc(width: f32, height: f32, length: f32, resX: i32, resY: i32, resZ: i32) -> Mesh ---

    /**
     * @brief Generate a slope mesh.
     * @param width Width along X axis.
     * @param height Height along Y axis.
     * @param length Length along Z axis.
     * @param slopeNormal Direction of the slope.
     * @return Mesh ready for rendering.
     * @see R3D_GenMeshDataSlope
     */
    GenMeshSlope :: proc(width: f32, height: f32, length: f32, slopeNormal: rl.Vector3) -> Mesh ---

    /**
     * @brief Generate a sphere mesh.
     * @param radius Sphere radius.
     * @param rings Number of latitude divisions.
     * @param slices Number of longitude divisions.
     * @return Mesh ready for rendering.
     * @see R3D_GenMeshDataSphere
     */
    GenMeshSphere :: proc(radius: f32, rings: i32, slices: i32) -> Mesh ---

    /**
     * @brief Generate a hemisphere mesh.
     * @param radius Hemisphere radius.
     * @param rings Number of latitude divisions.
     * @param slices Number of longitude divisions.
     * @return Mesh ready for rendering.
     * @see R3D_GenMeshDataHemiSphere
     */
    GenMeshHemiSphere :: proc(radius: f32, rings: i32, slices: i32) -> Mesh ---

    /**
     * @brief Generate a cylinder mesh.
     * @param bottomRadius Bottom radius.
     * @param topRadius Top radius.
     * @param height Height along Y axis.
     * @param slices Radial subdivisions.
     * @return Mesh ready for rendering.
     * @see R3D_GenMeshDataCylinder
     */
    GenMeshCylinder :: proc(bottomRadius: f32, topRadius: f32, height: f32, slices: i32) -> Mesh ---

    /**
     * @brief Generate a capsule mesh.
     * @param radius Capsule radius.
     * @param height Height along Y axis.
     * @param rings Number of latitude divisions.
     * @param slices Number of longitude divisions.
     * @return Mesh ready for rendering.
     * @see R3D_GenMeshDataCapsule
     */
    GenMeshCapsule :: proc(radius: f32, height: f32, rings: i32, slices: i32) -> Mesh ---

    /**
     * @brief Generate a torus mesh.
     * @param radius Major radius (center to tube).
     * @param size Minor radius (tube thickness).
     * @param radSeg Segments around major radius.
     * @param sides Sides around tube cross-section.
     * @return Mesh ready for rendering.
     * @see R3D_GenMeshDataTorus
     */
    GenMeshTorus :: proc(radius: f32, size: f32, radSeg: i32, sides: i32) -> Mesh ---

    /**
     * @brief Generate a trefoil knot mesh.
     * @param radius Major radius.
     * @param size Minor radius.
     * @param radSeg Segments around major radius.
     * @param sides Sides around tube cross-section.
     * @return Mesh ready for rendering.
     * @see R3D_GenMeshDataKnot
     */
    GenMeshKnot :: proc(radius: f32, size: f32, radSeg: i32, sides: i32) -> Mesh ---

    /**
     * @brief Generate a heightmap terrain mesh.
     * @param heightmap Heightmap image.
     * @param size 3D dimensions of terrain.
     * @return Mesh ready for rendering.
     * @see R3D_GenMeshDataHeightmap
     */
    GenMeshHeightmap :: proc(heightmap: rl.Image, size: rl.Vector3) -> Mesh ---

    /**
     * @brief Generate a cubicmap voxel mesh.
     * @param cubicmap Cubicmap image.
     * @param cubeSize Size of each cube.
     * @return Mesh ready for rendering.
     * @see R3D_GenMeshDataCubicmap
     */
    GenMeshCubicmap :: proc(cubicmap: rl.Image, cubeSize: rl.Vector3) -> Mesh ---

    /**
     * @brief Upload a mesh data on the GPU.
     *
     * This function uploads a mesh's vertex and optional index data to the GPU.
     *
     * If `aabb` is provided, it will be used as the mesh's bounding box; if null,
     * the bounding box is automatically recalculated from the vertex data.
     *
     * @param mesh Pointer to the mesh structure to update.
     * @param data Mesh data (vertices and indices) to upload.
     * @param aabb Optional bounding box; if null, it is recalculated automatically.
     * @return Returns true if the update is successful, false otherwise.
     */
    UpdateMesh :: proc(mesh: ^Mesh, data: MeshData, aabb: ^rl.BoundingBox) -> bool ---
}

