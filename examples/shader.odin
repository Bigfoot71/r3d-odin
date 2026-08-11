package shader

import rl "vendor:raylib"
import r3d "../r3d"

main :: proc() {
    // Initialize window
    rl.InitWindow(1152, 648, "[r3d] - Shader example")
    defer rl.CloseWindow()
    rl.SetTargetFPS(60)

    // Initialize R3D
    r3d.Init(rl.GetScreenWidth(), rl.GetScreenHeight())
    defer r3d.Close()

    // Setup environment
    env := r3d.GetEnvironment()
    env.ambient.color = {10, 10, 10, 255}
    env.bloom.mode = .ADDITIVE

    // Create meshes
    plane := r3d.GenMeshPlane(1000, 1000, 1, 1)
    torus := r3d.GenMeshTorus(0.5, 0.1, 32, 16)

    // Create material
    material := r3d.GetDefaultMaterial()
    material.shader = r3d.LoadSurfaceShader("./resources/shaders/material.glsl")

    // Generate a texture for custom sampler
    image := rl.GenImageChecked(512, 512, 16, 32, rl.WHITE, rl.BLACK)
    texture := rl.LoadTextureFromImage(image)
    rl.UnloadImage(image)

    // Set material custom uniform/sampler
    r3d.SetSurfaceShaderSampler(material.shader, "u_texture", texture)

    // Load a screen shader
    shader := r3d.LoadScreenShader("./resources/shaders/screen.glsl")
    r3d.SetScreenShaderChain(.OUTPUT, &shader, 1)

    // Set screen custom uniforms
    timeScale: f32 = 2.5
    r3d.SetScreenShaderUniform(shader, "u_time_scale", &timeScale)

    // Create light
    light := r3d.CreateSpotLight({0, 10, 5}, {0, -1, -0.5}, 50.0, rl.WHITE, 1.0)
    shadow := r3d.LoadShadowMap(.SPOT)
    shadow.softness = 4.0

    // Setup camera
    camera: rl.Camera3D = {
        position = {0, 2, 2},
        target   = {0, 0, 0},
        up       = {0, 1, 0},
        fovy     = 60,
    }

    // Main loop
    for !rl.WindowShouldClose() {
        rl.UpdateCamera(&camera, rl.CameraMode.ORBITAL)

        rl.BeginDrawing()
            rl.ClearBackground(rl.RAYWHITE)
            r3d.Begin(camera)
                r3d.PushLightEx(light, shadow, true)
                r3d.DrawMesh(plane, r3d.MATERIAL_BASE, {0, -0.5, 0}, 1.0)
                r3d.DrawMesh(torus, material, {0, 0, 0}, 1.0)
            r3d.End()
        rl.EndDrawing()
    }

    // Cleanup
    r3d.UnloadSurfaceShader(material.shader)
    r3d.UnloadScreenShader(shader)
    r3d.UnloadMesh(torus)
    r3d.UnloadMesh(plane)
}
