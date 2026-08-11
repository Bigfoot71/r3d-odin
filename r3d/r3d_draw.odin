/* r3d_draw.odin -- R3D Draw Module.
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
 * @brief Describes an R3D rendering view.
 *
 * A view defines the camera and output area used for a single rendering
 * session. It combines an R3D camera, an optional render target and an optional
 * viewport inside that target.
 *
 * If `target` is zero-initialized, rendering is directed to the default
 * framebuffer. If `viewport.width` or `viewport.height` is less than or equal
 * to zero, the full target size is used.
 */
View :: struct {
    camera:   Camera,        ///< Camera used for this view.
    target:   rl.RenderTexture, ///< Render target. Zero-initialized means screen/backbuffer.
    viewport: rl.Rectangle,     ///< Viewport inside the target. If width or height <= 0, the full target is used.
}

@(default_calling_convention="c", link_prefix="R3D_")
foreign lib {
    /**
     * @brief Begins a rendering session using the given raylib camera.
     *
     * Rendering output is directed to the default framebuffer.
     *
     * The given rl.Camera3D is converted internally to an R3D_Camera. Since raylib
     * cameras do not store near/far clipping planes, the converted camera uses the
     * current rlgl culling distances for those values.
     *
     * @param camera Camera used to render the scene.
     */
    Begin :: proc(camera: rl.Camera3D) ---

    /**
     * @brief Begins a rendering session using an R3D camera.
     *
     * Rendering output is directed to the default framebuffer.
     *
     * This entry point provides access to R3D-specific camera features such as
     * layer masks, custom near/far clipping planes and quaternion-based orientation.
     *
     * @param camera Camera used to render the scene.
     */
    BeginEx :: proc(camera: Camera) ---

    /**
     * @brief Begins a rendering session using a complete R3D view descriptor.
     *
     * This is the advanced entry point. It allows the caller to specify the camera,
     * render target and viewport used for the rendering session.
     *
     * The view camera is used as-is, including its near/far clipping planes and
     * layer mask. If the camera was created from a raylib rl.Camera3D using
     * `R3D_CameraFromRL()`, its near/far planes come from the current rlgl culling
     * distances because raylib cameras do not store those values directly.
     *
     * Use this function for render-to-texture workflows, custom viewports,
     * multipass rendering, editor views, minimaps, probes or any case where the
     * default framebuffer is not enough.
     *
     * @param view View descriptor used to render the scene.
     */
    BeginPro :: proc(view: View) ---

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
     * @brief Queues a light to be rendered for the current frame, without shadows.
     *
     * The light is submitted for rendering during R3D_End(), and must be pushed
     * again on every frame between R3D_Begin() and R3D_End() to remain visible.
     *
     * @param light The light data to submit (see R3D_Light).
     */
    PushLight :: proc(light: Light) ---

    /**
     * @brief Queues a light to be rendered for the current frame, with an associated shadow map.
     *
     * The light is submitted for rendering during R3D_End(), and must be pushed
     * again on every frame between R3D_Begin() and R3D_End() to remain visible.
     *
     * The shadow map is re-rendered whenever updateShadow is true, or when it has never
     * been rendered before (so static lights can safely pass false from the start and
     * still get valid shadows). This happens even if the light is currently off-screen,
     * so you can safely ignore visibility when driving updateShadow, or factor it in
     * yourself if you want to defer updates for off-screen lights.
     *
     * @param light The light data to submit (see R3D_Light).
     * @param map The shadow map to associate with this light for this frame.
     * @param updateShadow Whether the shadow map should be re-rendered this frame.
     *                     If false, the previously rendered content is reused instead.
     */
    PushLightEx :: proc(light: Light, _map: ShadowMap, updateShadow: bool) ---

    /**
     * @brief Queues a probe to be rendered for the current frame.
     *
     * The probe is submitted for rendering during R3D_End(), and must be pushed
     * again on every frame between R3D_Begin() and R3D_End() to remain active.
     *
     * The probe is re-captured whenever updateProbe is true, or when it has never been
     * captured before (so static probes can safely pass false from the start and still
     * get valid data). This happens even if the probe is currently off-screen, so you
     * can safely ignore visibility when driving updateProbe, or factor it in yourself
     * if you want to defer updates for off-screen probes.
     *
     * @param probe The probe data to submit (see R3D_Probe).
     * @param updateProbe Whether the probe's capture should be re-rendered this frame.
     *                    If false, the previously captured content is reused instead.
     */
    PushProbe :: proc(probe: Probe, updateProbe: bool) ---

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
     * Does nothing if the number of instances is <= 0.
     *
     * The command is executed during R3D_End().
     */
    DrawMeshInstanced :: proc(mesh: Mesh, material: Material, instances: InstanceBuffer, count: i32) ---

    /**
     * @brief Queues an instanced mesh draw command with an instance range.
     *
     * Draws 'count' instances starting at 'offset' in the instance buffer.
     * Both 'offset' and 'count' are clamped to stay within [0, instances.capacity]:
     *   - offset is clamped to [0, capacity]
     *   - count is clamped to [0, capacity - offset]
     * Does nothing if the resulting count is <= 0.
     *
     * The command is executed during R3D_End().
     */
    DrawMeshInstancedEx :: proc(mesh: Mesh, material: Material, instances: InstanceBuffer, offset: i32, count: i32) ---

    /**
     * @brief Queues an instanced mesh draw command with an instance range and an additional transform.
     *
     * Draws 'count' instances starting at 'offset' in the instance buffer.
     * Both 'offset' and 'count' are clamped to stay within [0, instances.capacity]:
     *   - offset is clamped to [0, capacity]
     *   - count is clamped to [0, capacity - offset]
     * Does nothing if the resulting count is <= 0.
     * The transform is applied to all instances.
     *
     * The command is executed during R3D_End().
     */
    DrawMeshInstancedPro :: proc(mesh: Mesh, material: Material, instances: InstanceBuffer, offset: i32, count: i32, transform: rl.Matrix) ---

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
     * Does nothing if the number of instances is <= 0.
     *
     * The command is executed during R3D_End().
     */
    DrawModelInstanced :: proc(model: Model, instances: InstanceBuffer, count: i32) ---

    /**
     * @brief Queues an instanced model draw command with an instance range.
     *
     * Draws 'count' instances starting at 'offset' in the instance buffer.
     * Both 'offset' and 'count' are clamped to stay within [0, instances.capacity]:
     *   - offset is clamped to [0, capacity]
     *   - count is clamped to [0, capacity - offset]
     * Does nothing if the resulting count is <= 0.
     *
     * The command is executed during R3D_End().
     */
    DrawModelInstancedEx :: proc(model: Model, instances: InstanceBuffer, offset: i32, count: i32) ---

    /**
     * @brief Queues an instanced model draw command with an instance range and an additional transform.
     *
     * Draws 'count' instances starting at 'offset' in the instance buffer.
     * Both 'offset' and 'count' are clamped to stay within [0, instances.capacity]:
     *   - offset is clamped to [0, capacity]
     *   - count is clamped to [0, capacity - offset]
     * Does nothing if the resulting count is <= 0.
     * The transform is applied to all instances.
     *
     * The command is executed during R3D_End().
     */
    DrawModelInstancedPro :: proc(model: Model, instances: InstanceBuffer, offset: i32, count: i32, transform: rl.Matrix) ---

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
     * Does nothing if the number of instances is <= 0.
     *
     * The command is executed during R3D_End().
     */
    DrawAnimatedModelInstanced :: proc(model: Model, player: AnimationPlayer, instances: InstanceBuffer, count: i32) ---

    /**
     * @brief Queues an instanced animated model draw command with an instance range.
     *
     * Draws 'count' animated instances starting at 'offset' in the instance buffer.
     * Both 'offset' and 'count' are clamped to stay within [0, instances.capacity]:
     *   - offset is clamped to [0, capacity]
     *   - count is clamped to [0, capacity - offset]
     * Does nothing if the resulting count is <= 0.
     *
     * The command is executed during R3D_End().
     */
    DrawAnimatedModelInstancedEx :: proc(model: Model, player: AnimationPlayer, instances: InstanceBuffer, offset: i32, count: i32) ---

    /**
     * @brief Queues an instanced animated model draw command with an instance range and an additional transform.
     *
     * Draws 'count' animated instances starting at 'offset' in the instance buffer.
     * Both 'offset' and 'count' are clamped to stay within [0, instances.capacity]:
     *   - offset is clamped to [0, capacity]
     *   - count is clamped to [0, capacity - offset]
     * Does nothing if the resulting count is <= 0.
     * The transform is applied to all instances.
     *
     * The command is executed during R3D_End().
     */
    DrawAnimatedModelInstancedPro :: proc(model: Model, player: AnimationPlayer, instances: InstanceBuffer, offset: i32, count: i32, transform: rl.Matrix) ---

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
     * Does nothing if the number of instances is <= 0.
     *
     * The command is executed during R3D_End().
     */
    DrawDecalInstanced :: proc(decal: Decal, instances: InstanceBuffer, count: i32) ---

    /**
     * @brief Queues an instanced decal draw command with an instance range.
     *
     * Draws 'count' instances starting at 'offset' in the instance buffer.
     * Both 'offset' and 'count' are clamped to stay within [0, instances.capacity]:
     *   - offset is clamped to [0, capacity]
     *   - count is clamped to [0, capacity - offset]
     * Does nothing if the resulting count is <= 0.
     *
     * The command is executed during R3D_End().
     */
    DrawDecalInstancedEx :: proc(decal: Decal, instances: InstanceBuffer, offset: i32, count: i32) ---

    /**
     * @brief Queues an instanced decal draw command with an instance range and an additional transform.
     *
     * Draws 'count' instances starting at 'offset' in the instance buffer.
     * Both 'offset' and 'count' are clamped to stay within [0, instances.capacity]:
     *   - offset is clamped to [0, capacity]
     *   - count is clamped to [0, capacity - offset]
     * Does nothing if the resulting count is <= 0.
     * The transform is applied to all instances.
     *
     * The command is executed during R3D_End().
     */
    DrawDecalInstancedPro :: proc(decal: Decal, instances: InstanceBuffer, offset: i32, count: i32, transform: rl.Matrix) ---
}

