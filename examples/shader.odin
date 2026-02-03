package shader

import rl "vendor:raylib"
import r3d "../r3d"

main :: proc() {
    // Initialize window
    rl.InitWindow(800, 450, "[r3d] - Shader example")
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
    defer r3d.UnloadMesh(plane)
    torus := r3d.GenMeshTorus(0.5, 0.1, 32, 16)
    defer r3d.UnloadMesh(torus)

    // Create material
    material := r3d.GetDefaultMaterial()
    material.shader = r3d.LoadSurfaceShader("./resources/shaders/material.glsl")
    defer r3d.UnloadSurfaceShader(material.shader)

    // Generate a texture for custom sampler
    image := rl.GenImageChecked(512, 512, 16, 32, rl.WHITE, rl.BLACK)
    texture := rl.LoadTextureFromImage(image)
    defer rl.UnloadTexture(texture)
    rl.UnloadImage(image)

    // Set custom sampler
    r3d.SetSurfaceShaderSampler(material.shader, "u_texture", texture)

    // Load a screen shader
    shader := r3d.LoadScreenShader("./resources/shaders/screen.glsl")
    defer r3d.UnloadScreenShader(shader)
    shaderPtr := shader
    r3d.SetScreenShaderChain(&shaderPtr, 1)

    // Create light
    light := r3d.CreateLight(.SPOT)
    r3d.LightLookAt(light, {0, 10, 5}, {0, 0, 0})
    r3d.EnableShadow(light)
    r3d.SetLightActive(light, true)

    // Setup camera
    camera: rl.Camera3D = {
        position = {0, 2, 2},
        target = {0, 0, 0},
        up = {0, 1, 0},
        fovy = 60,
    }

    // Main loop
    for !rl.WindowShouldClose()
    {
        rl.UpdateCamera(&camera, rl.CameraMode.ORBITAL)

        rl.BeginDrawing()
            rl.ClearBackground(rl.RAYWHITE)

            time := 2.0 * f32(rl.GetTime())
            r3d.SetScreenShaderUniform(shader, "u_time", &time)
            r3d.SetSurfaceShaderUniform(material.shader, "u_time", &time)

            r3d.Begin(camera)
                r3d.DrawMesh(plane, r3d.GetDefaultMaterial(), {0, -0.5, 0}, 1.0)
                r3d.DrawMesh(torus, material, {0, 0, 0}, 1.0)
            r3d.End()

        rl.EndDrawing()
    }
}
