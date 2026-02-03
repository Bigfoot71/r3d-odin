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
    rl.InitWindow(800, 450, "[r3d] - Many lights example")
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
    defer r3d.UnloadMesh(plane)
    cube := r3d.GenMeshCube(0.5, 0.5, 0.5)
    defer r3d.UnloadMesh(cube)
    material := r3d.GetDefaultMaterial()

    // Allocate transforms for all spheres
    instances := r3d.LoadInstanceBuffer(GRID_SIZE * GRID_SIZE, {.POSITION})
    defer r3d.UnloadInstanceBuffer(instances)
    positions := cast([^]rl.Vector3)r3d.MapInstances(instances, {.POSITION})
    for x in -50..<50 {
        for z in -50..<50 {
            positions[(z+50)*GRID_SIZE + (x+50)] = {f32(x) + 0.5, 0, f32(z) + 0.5}
        }
    }
    r3d.UnmapInstances(instances, {.POSITION})

    // Create lights
    lights: [NUM_LIGHTS]r3d.Light
    for i in 0..<NUM_LIGHTS {
        lights[i] = r3d.CreateLight(.OMNI)
        r3d.SetLightPosition(lights[i], {randf(-50.0, 50.0), randf(1.0, 5.0), randf(-50.0, 50.0)})
        r3d.SetLightColor(lights[i], rl.ColorFromHSV(randf(0.0, 360.0), 1.0, 1.0))
        r3d.SetLightRange(lights[i], randf(8.0, 16.0))
        r3d.SetLightActive(lights[i], true)
    }

    // Setup camera
    camera: rl.Camera3D = {
        position = {0, 10, 10},
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

            // Draw scene
            r3d.Begin(camera)
                r3d.DrawMesh(plane, material, {0, -0.25, 0}, 1.0)
                r3d.DrawMeshInstanced(cube, material, instances, GRID_SIZE*GRID_SIZE)
            r3d.End()

            // Optionally show lights shapes
            if rl.IsKeyDown(.F) {
                rl.BeginMode3D(camera)
                    for i in 0..<NUM_LIGHTS {
                        r3d.DrawLightShape(lights[i])
                    }
                rl.EndMode3D()
            }

            rl.DrawFPS(10, 10)
            rl.DrawText("Press 'F' to show the lights", 10, rl.GetScreenHeight()-34, 24, rl.BLACK)

        rl.EndDrawing()
    }
}
