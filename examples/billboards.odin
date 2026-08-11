package billboards

import rl "vendor:raylib"
import r3d "../r3d"

main :: proc() {
    // Initialize window
    rl.InitWindow(1152, 648, "[r3d] - Billboards example")
    defer rl.CloseWindow()
    rl.SetTargetFPS(60)

    // Initialize R3D
    r3d.Init(rl.GetScreenWidth(), rl.GetScreenHeight())
    defer r3d.Close()
    r3d.SetTextureFilter(.POINT)

    // Set background/ambient color
    env := r3d.GetEnvironment()
    env.background.color = {102, 191, 255, 255}
    env.ambient.color = {10, 19, 25, 255}
    env.tonemap.mode = .FILMIC

    // Create ground mesh and material
    meshGround := r3d.GenMeshPlane(200, 200, 1, 1)
    matGround := r3d.GetDefaultMaterial()
    matGround.albedo.color = rl.GREEN

    // Create billboard mesh and material
    meshBillboard := r3d.GenMeshQuad(1.0, 1.0, 1, 1, {0.0, 0.0, 1.0})
    meshBillboard.shadowCastMode = .ON_DOUBLE_SIDED

    matBillboard := r3d.GetDefaultMaterial()
    matBillboard.albedo = r3d.LoadAlbedoMap("./resources/images/tree.png", rl.WHITE)
    matBillboard.billboardMode = .Y_AXIS

    // Create transforms for instanced billboards
    instances := r3d.LoadInstanceBuffer(64, {.POSITION, .SCALE})
    positions := cast([^]rl.Vector3)r3d.MapInstances(instances, {.POSITION}, false)
    scales := cast([^]rl.Vector3)r3d.MapInstances(instances, {.SCALE}, false)
    for i in 0..<64 {
        scaleFactor := f32(rl.GetRandomValue(25, 50)) / 10.0
        scales[i] = {scaleFactor, scaleFactor, 1.0}
        positions[i] = {
            f32(rl.GetRandomValue(-100, 100)),
            scaleFactor * 0.5,
            f32(rl.GetRandomValue(-100, 100)),
        }
    }
    r3d.UnmapInstances(instances, {.POSITION, .SCALE})

    // Setup directional light with shadows
    light := r3d.CreateDirLight({-1, -1, -1}, rl.WHITE, 1.0)
    shadow := r3d.LoadShadowMap(.DIR)

    // Setup camera
    camera: rl.Camera3D = {
        position = {0, 5, 0},
        target   = {0, 5, -1},
        up       = {0, 1, 0},
        fovy     = 60,
    }

    // Capture mouse
    rl.DisableCursor()

    // Main loop
    for !rl.WindowShouldClose() {
        rl.UpdateCamera(&camera, rl.CameraMode.FREE)

        rl.BeginDrawing()
            rl.ClearBackground(rl.RAYWHITE)

            r3d.Begin(camera)
                r3d.PushLightEx(light, shadow, true)
                r3d.DrawMesh(meshGround, matGround, {0, 0, 0}, 1.0)
                r3d.DrawMeshInstanced(meshBillboard, matBillboard, instances, 64)
            r3d.End()

        rl.EndDrawing()
    }

    // Cleanup
    r3d.UnloadMaterial(matBillboard)
    r3d.UnloadMesh(meshBillboard)
    r3d.UnloadMesh(meshGround)
}
