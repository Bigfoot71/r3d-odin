package lights

import rl "vendor:raylib"
import "core:math/rand"
import r3d "../r3d"

NUM_LIGHTS :: 128
GRID_SIZE :: 100

randf :: proc(min: f32, max: f32) -> f32 {
    return min + (max - min) * rand.float32()
}

main :: proc() {
    // Initialize window
    rl.InitWindow(1152, 648, "[r3d] - Many lights example")
    defer rl.CloseWindow()
    rl.SetTargetFPS(60)

    // Initialize R3D
    r3d.Init(rl.GetScreenWidth(), rl.GetScreenHeight())
    defer r3d.Close()

    // Set ambient light
    env := r3d.GetEnvironment()
    env.background.color = rl.BLACK
    env.ambient.color = {10, 10, 10, 255}

    // Create plane and cube meshes
    plane := r3d.GenMeshPlane(100, 100, 1, 1)
    cube := r3d.GenMeshCube(0.5, 0.5, 0.5)
    material := r3d.GetDefaultMaterial()

    // Allocate transforms for all spheres
    instances := r3d.LoadInstanceBuffer(GRID_SIZE * GRID_SIZE, {.POSITION})
    positions := cast([^]rl.Vector3)r3d.MapInstances(instances, {.POSITION}, false)
    for x in -50..<50 {
        for z in -50..<50 {
            positions[(z+50)*GRID_SIZE + (x+50)] = {f32(x) + 0.5, 0, f32(z) + 0.5}
        }
    }
    r3d.UnmapInstances(instances, {.POSITION})

    // Create lights
    lights: [NUM_LIGHTS]r3d.Light
    for i in 0..<NUM_LIGHTS {
        lights[i] = r3d.CreateOmniLight({0, 0, 0}, 0.0, rl.WHITE, 1.0)
        lights[i].position = {randf(-50.0, 50.0), randf(1.0, 5.0), randf(-50.0, 50.0)}
        lights[i].color    = rl.ColorFromHSV(randf(0.0, 360.0), 1.0, 1.0)
        lights[i].range    = randf(8.0, 16.0)
    }

    // Setup camera
    camera: rl.Camera3D = {
        position = {0, 10, 10},
        target   = {0, 0, 0},
        up       = {0, 1, 0},
        fovy     = 60,
    }

    // Main loop
    for !rl.WindowShouldClose() {
        rl.UpdateCamera(&camera, rl.CameraMode.ORBITAL)

        rl.BeginDrawing()
        rl.ClearBackground(rl.RAYWHITE)

        // Draw scene
        r3d.Begin(camera)
            for i in 0..<NUM_LIGHTS {
                r3d.PushLight(lights[i])
            }
            r3d.DrawMesh(plane, material, {0, -0.25, 0}, 1.0)
            r3d.DrawMeshInstanced(cube, material, instances, GRID_SIZE*GRID_SIZE)
        r3d.End()

        // Optionally show lights shapes
        if rl.IsKeyDown(.F) {
            rl.BeginMode3D(camera)
            for i in 0..<NUM_LIGHTS {
                r3d.DrawLightDebug(lights[i])
            }
            rl.EndMode3D()
        }

        rl.DrawFPS(10, 10)
        rl.DrawText("Press 'F' to show the lights", 10, rl.GetScreenHeight()-34, 24, rl.BLACK)

        rl.EndDrawing()
    }

    // Cleanup
    r3d.UnloadInstanceBuffer(instances)
    r3d.UnloadMesh(cube)
    r3d.UnloadMesh(plane)
}
