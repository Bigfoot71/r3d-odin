package instanced

import rl "vendor:raylib"
import r3d "../r3d"

INSTANCE_COUNT :: 1000

main :: proc() {
    // Initialize window
    rl.InitWindow(800, 450, "[r3d] - Instanced rendering example")
    defer rl.CloseWindow()
    rl.SetTargetFPS(60)

    // Initialize R3D
    r3d.Init(rl.GetScreenWidth(), rl.GetScreenHeight())
    defer r3d.Close()

    // Set ambient light
    env := r3d.GetEnvironment()
    env.ambient.color = rl.DARKGRAY

    // Create cube mesh and default material
    mesh := r3d.GenMeshCube(1, 1, 1)
    defer r3d.UnloadMesh(mesh)
    material := r3d.GetDefaultMaterial()
    defer r3d.UnloadMaterial(material)

    // Generate random transforms and colors for instances
    instances := r3d.LoadInstanceBuffer(INSTANCE_COUNT, {.POSITION, .ROTATION, .SCALE, .COLOR})
    defer r3d.UnloadInstanceBuffer(instances)
    positions := cast([^]rl.Vector3)r3d.MapInstances(instances, {.POSITION})
    rotations := cast([^]rl.Quaternion)r3d.MapInstances(instances, {.ROTATION})
    scales := cast([^]rl.Vector3)r3d.MapInstances(instances, {.SCALE})
    colors := cast([^]rl.Color)r3d.MapInstances(instances, {.COLOR})

    for i in 0..<INSTANCE_COUNT
    {
        positions[i] = {
            f32(rl.GetRandomValue(-50000, 50000)) / 1000,
            f32(rl.GetRandomValue(-50000, 50000)) / 1000,
            f32(rl.GetRandomValue(-50000, 50000)) / 1000,
        }
        rotations[i] = rl.QuaternionFromEuler(
            f32(rl.GetRandomValue(-314000, 314000)) / 100000,
            f32(rl.GetRandomValue(-314000, 314000)) / 100000,
            f32(rl.GetRandomValue(-314000, 314000)) / 100000,
        )
        scales[i] = {
            f32(rl.GetRandomValue(100, 2000)) / 1000,
            f32(rl.GetRandomValue(100, 2000)) / 1000,
            f32(rl.GetRandomValue(100, 2000)) / 1000,
        }
        colors[i] = rl.ColorFromHSV(
            f32(rl.GetRandomValue(0, 360000)) / 1000, 1.0, 1.0,
        )
    }

    r3d.UnmapInstances(instances, {.POSITION, .ROTATION, .SCALE, .COLOR})

    // Setup directional light
    light := r3d.CreateLight(.DIR)
    r3d.SetLightDirection(light, {0, -1, 0})
    r3d.SetLightActive(light, true)

    // Setup camera
    camera: rl.Camera3D = {
        position = {0, 2, 2},
        target = {0, 0, 0},
        up = {0, 1, 0},
        fovy = 60,
    }

    // Capture mouse
    rl.DisableCursor()

    // Main loop
    for !rl.WindowShouldClose()
    {
        rl.UpdateCamera(&camera, rl.CameraMode.FREE)

        rl.BeginDrawing()
            rl.ClearBackground(rl.RAYWHITE)

            r3d.Begin(camera)
                r3d.DrawMeshInstanced(mesh, material, instances, INSTANCE_COUNT)
            r3d.End()

            rl.DrawFPS(10, 10)
        rl.EndDrawing()
    }
}
