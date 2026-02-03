/* r3d_draw.odin -- R3D Draw Module.
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
     * @brief Begins a rendering session using the given camera.
     *
     * Rendering output is directed to the default framebuffer.
     *
     * @param camera rl.Camera used to render the scene.
     */
    Begin :: proc(camera: rl.Camera3D) ---

    /**
     * @brief Begins a rendering session with a custom render target.
     *
     * If the render target is invalid (ID = 0), rendering goes to the screen.
     *
     * @param target Render texture to render into.
     * @param camera rl.Camera used to render the scene.
     */
    BeginEx :: proc(target: rl.RenderTexture, camera: rl.Camera3D) ---

    /**
     * @brief Ends the current rendering session.
     *
     * This function is the one that actually performs the full
     * rendering of the described scene. It carries out culling,
     * sorting, shadow rendering, scene rendering, and screen /
     * post-processing effects.
     */
    End :: proc() ---

    /**
     * @brief Begins a clustered draw pass.
     *
     * All draw calls submitted in this pass are first tested against the
     * cluster AABB. If the cluster fails the scene/shadow frustum test,
     * none of the contained objects are tested or drawn.
     *
     * @param aabb Bounding box used as the cluster-level frustum test.
     */
    BeginCluster :: proc(aabb: rl.BoundingBox) ---

    /**
     * @brief Ends the current clustered draw pass.
     *
     * Stops submitting draw calls to the active cluster.
     */
    EndCluster :: proc() ---

    /**
     * @brief Queues a mesh draw command with position and uniform scale.
     *
     * The command is executed during R3D_End().
     */
    DrawMesh :: proc(mesh: Mesh, material: Material, position: rl.Vector3, scale: f32) ---

    /**
     * @brief Queues a mesh draw command with position, rotation and non-uniform scale.
     *
     * The command is executed during R3D_End().
     */
    DrawMeshEx :: proc(mesh: Mesh, material: Material, position: rl.Vector3, rotation: rl.Quaternion, scale: rl.Vector3) ---

    /**
     * @brief Queues a mesh draw command using a full transform matrix.
     *
     * The command is executed during R3D_End().
     */
    DrawMeshPro :: proc(mesh: Mesh, material: Material, transform: rl.Matrix) ---

    /**
     * @brief Queues an instanced mesh draw command.
     *
     * Draws multiple instances using the provided instance buffer.
     *
     * The command is executed during R3D_End().
     */
    DrawMeshInstanced :: proc(mesh: Mesh, material: Material, instances: InstanceBuffer, count: i32) ---

    /**
     * @brief Queues an instanced mesh draw command with an additional transform.
     *
     * The transform is applied to all instances.
     *
     * The command is executed during R3D_End().
     */
    DrawMeshInstancedEx :: proc(mesh: Mesh, material: Material, instances: InstanceBuffer, count: i32, transform: rl.Matrix) ---

    /**
     * @brief Queues a model draw command with position and uniform scale.
     *
     * The command is executed during R3D_End().
     */
    DrawModel :: proc(model: Model, position: rl.Vector3, scale: f32) ---

    /**
     * @brief Queues a model draw command with position, rotation and non-uniform scale.
     *
     * The command is executed during R3D_End().
     */
    DrawModelEx :: proc(model: Model, position: rl.Vector3, rotation: rl.Quaternion, scale: rl.Vector3) ---

    /**
     * @brief Queues a model draw command using a full transform matrix.
     *
     * The command is executed during R3D_End().
     */
    DrawModelPro :: proc(model: Model, transform: rl.Matrix) ---

    /**
     * @brief Queues an instanced model draw command.
     *
     * Draws multiple instances using the provided instance buffer.
     *
     * The command is executed during R3D_End().
     */
    DrawModelInstanced :: proc(model: Model, instances: InstanceBuffer, count: i32) ---

    /**
     * @brief Queues an instanced model draw command with an additional transform.
     *
     * The transform is applied to all instances.
     *
     * The command is executed during R3D_End().
     */
    DrawModelInstancedEx :: proc(model: Model, instances: InstanceBuffer, count: i32, transform: rl.Matrix) ---

    /**
     * @brief Queues an animated model draw command.
     *
     * Uses the provided animation player to compute the pose.
     *
     * The command is executed during R3D_End().
     */
    DrawAnimatedModel :: proc(model: Model, player: AnimationPlayer, position: rl.Vector3, scale: f32) ---

    /**
     * @brief Queues an animated model draw command with position, rotation and non-uniform scale.
     *
     * Uses the provided animation player to compute the pose.
     *
     * The command is executed during R3D_End().
     */
    DrawAnimatedModelEx :: proc(model: Model, player: AnimationPlayer, position: rl.Vector3, rotation: rl.Quaternion, scale: rl.Vector3) ---

    /**
     * @brief Queues an animated model draw command using a full transform matrix.
     *
     * The command is executed during R3D_End().
     */
    DrawAnimatedModelPro :: proc(model: Model, player: AnimationPlayer, transform: rl.Matrix) ---

    /**
     * @brief Queues an instanced animated model draw command.
     *
     * Draws multiple animated instances using the provided instance buffer.
     *
     * The command is executed during R3D_End().
     */
    DrawAnimatedModelInstanced :: proc(model: Model, player: AnimationPlayer, instances: InstanceBuffer, count: i32) ---

    /**
     * @brief Queues an instanced animated model draw command with an additional transform.
     *
     * The transform is applied to all instances.
     *
     * The command is executed during R3D_End().
     */
    DrawAnimatedModelInstancedEx :: proc(model: Model, player: AnimationPlayer, instances: InstanceBuffer, count: i32, transform: rl.Matrix) ---

    /**
     * @brief Queues a decal draw command with position and uniform scale.
     *
     * The command is executed during R3D_End().
     */
    DrawDecal :: proc(decal: Decal, position: rl.Vector3, scale: f32) ---

    /**
     * @brief Queues a decal draw command with position, rotation and non-uniform scale.
     *
     * The command is executed during R3D_End().
     */
    DrawDecalEx :: proc(decal: Decal, position: rl.Vector3, rotation: rl.Quaternion, scale: rl.Vector3) ---

    /**
     * @brief Queues a decal draw command using a full transform matrix.
     *
     * The command is executed during R3D_End().
     */
    DrawDecalPro :: proc(decal: Decal, transform: rl.Matrix) ---

    /**
     * @brief Queues an instanced decal draw command.
     *
     * Draws multiple instances using the provided instance buffer.
     *
     * The command is executed during R3D_End().
     */
    DrawDecalInstanced :: proc(decal: Decal, instances: InstanceBuffer, count: i32) ---

    /**
     * @brief Queues an instanced decal draw command with an additional transform.
     *
     * The transform is applied to all instances.
     *
     * The command is executed during R3D_End().
     */
    DrawDecalInstancedEx :: proc(decal: Decal, instances: InstanceBuffer, count: i32, transform: rl.Matrix) ---
}

