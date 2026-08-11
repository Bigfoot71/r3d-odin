package transparency

import rl "vendor:raylib"
import r3d "../r3d"

main :: proc() {
    // Initialize window
    rl.InitWindow(1152, 648, "[r3d] - Transparency example")
    defer rl.CloseWindow()
    rl.SetTargetFPS(60)

    // Initialize R3D
    r3d.Init(rl.GetScreenWidth(), rl.GetScreenHeight())
    defer r3d.Close()

    // Create cube model
    cube := r3d.GenMeshCube(1, 1, 1)
    matCube := r3d.MATERIAL_BASE
    matCube.transparencyMode = .ALPHA
    matCube.albedo.color = {150, 150, 255, 100}
    matCube.orm.occlusion = 1.0
    matCube.orm.roughness = 0.2
    matCube.orm.metalness = 0.2

    // Create plane model
    plane := r3d.GenMeshPlane(1000, 1000, 1, 1)
    matPlane := r3d.MATERIAL_BASE
    matPlane.orm.occlusion = 1.0
    matPlane.orm.roughness = 1.0
    matPlane.orm.metalness = 0.0

    // Create sphere model
    sphere := r3d.GenMeshSphere(0.5, 64, 64)
    matSphere := r3d.MATERIAL_BASE
    matSphere.orm.occlusion = 1.0
    matSphere.orm.roughness = 0.25
    matSphere.orm.metalness = 0.75

    // Setup camera
    camera: rl.Camera3D = {
        position = {0, 2, 2},
        target   = {0, 0, 0},
        up       = {0, 1, 0},
        fovy     = 60,
    }

    // Setup environment
    env := r3d.GetEnvironment()
    env.ambient.color = {10, 10, 10, 255}

    // Create light
    light := r3d.CreateSpotLight({0, 10, 5}, {0, -1, -0.5}, 50.0, rl.WHITE, 1.0)
    shadow := r3d.LoadShadowMap(.SPOT)
    shadow.softness = 4.0

    // Main loop
    for !rl.WindowShouldClose() {
        rl.UpdateCamera(&camera, rl.CameraMode.ORBITAL)

        rl.BeginDrawing()
            rl.ClearBackground(rl.RAYWHITE)

            r3d.Begin(camera)
                r3d.PushLightEx(light, shadow, false)
                r3d.DrawMesh(plane, matPlane, {0, -0.5, 0}, 1.0)
                r3d.DrawMesh(sphere, matSphere, {0, 0, 0}, 1.0)
                r3d.DrawMesh(cube, matCube, {0, 0, 0}, 1.0)
            r3d.End()

        rl.EndDrawing()
    }

    // Cleanup
    r3d.UnloadMesh(sphere)
    r3d.UnloadMesh(plane)
    r3d.UnloadMesh(cube)
}
