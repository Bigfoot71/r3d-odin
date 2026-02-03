package basic

import rl "vendor:raylib"
import r3d "../r3d"

main :: proc() {
    // Initialize window
    rl.InitWindow(800, 450, "[r3d] - Basic example")
    defer rl.CloseWindow()
    rl.SetTargetFPS(60)

    // Initialize R3D
    r3d.Init(rl.GetScreenWidth(), rl.GetScreenHeight())
    defer r3d.Close()

    // Create meshes
    plane := r3d.GenMeshPlane(1000, 1000, 1, 1)
    sphere := r3d.GenMeshSphere(0.5, 64, 64)
    material := r3d.GetDefaultMaterial()

    // Setup environment
    env := r3d.GetEnvironment()
    env.ambient.color = {10, 10, 10, 255}

    // Create light
    light := r3d.CreateLight(.SPOT)
    r3d.LightLookAt(light, {0, 10, 5}, {0, 0, 0})
    r3d.SetLightActive(light, true)
    r3d.EnableShadow(light)

    // Setup camera
    camera: rl.Camera3D = {
        position = {0, 2, 2},
        target = {0, 0, 0},
        up = {0, 1, 0},
        fovy = 60
    }

    // Main loop
    for !rl.WindowShouldClose()
    {
        rl.UpdateCamera(&camera, rl.CameraMode.ORBITAL)

        rl.BeginDrawing()
            rl.ClearBackground(rl.RAYWHITE)

            r3d.Begin(camera)
                r3d.DrawMesh(plane, material, {0, -0.5, 0}, 1.0)
                r3d.DrawMesh(sphere, material, {0, 0, 0}, 1.0)
            r3d.End()

        rl.EndDrawing()
    }

    // Cleanup
    r3d.UnloadMesh(sphere)
    r3d.UnloadMesh(plane)
}
