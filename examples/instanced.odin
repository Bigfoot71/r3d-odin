package instanced

import rl "vendor:raylib"
import r3d "../r3d"

INSTANCE_COUNT :: 1000

Packed_Rotation :: struct {
    x, y, z, w: i16,
}

Packed_Scale :: struct {
    x, y, z: u16,
}

main :: proc() {
    // Initialize window
    rl.InitWindow(1152, 648, "[r3d] - Instanced rendering example")
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
    material := r3d.GetDefaultMaterial()

    layout := r3d.InstanceLayout {
        formats = {
            .FLOAT32,  // position
            .SNORM16,  // rotation quaternion
            .FLOAT16,  // scale
            .UNORM8,   // color
            .FLOAT32,  // custom (unused)
        },
        flags = {
            .POSITION,
            .ROTATION,
            .SCALE,
            .COLOR
        },
    }

    instances := r3d.LoadInstanceBufferEx(INSTANCE_COUNT, layout)

    positions := cast([^]rl.Vector3)r3d.MapInstances(instances, {.POSITION}, false)
    rotations := cast([^]Packed_Rotation)r3d.MapInstances(instances, {.ROTATION}, false)
    scales := cast([^]Packed_Scale)r3d.MapInstances(instances, {.SCALE}, false)
    colors := cast([^]rl.Color)r3d.MapInstances(instances, {.COLOR}, false)

    for i in 0..<INSTANCE_COUNT {
        positions[i] = {
            f32(rl.GetRandomValue(-50000, 50000)) / 1000.0,
            f32(rl.GetRandomValue(-50000, 50000)) / 1000.0,
            f32(rl.GetRandomValue(-50000, 50000)) / 1000.0,
        }

        rotation := rl.QuaternionFromEuler(
            f32(rl.GetRandomValue(-314000, 314000)) / 100000.0,
            f32(rl.GetRandomValue(-314000, 314000)) / 100000.0,
            f32(rl.GetRandomValue(-314000, 314000)) / 100000.0,
        )

        rotations[i] = {
            r3d.PackSnorm16(rotation.x),
            r3d.PackSnorm16(rotation.y),
            r3d.PackSnorm16(rotation.z),
            r3d.PackSnorm16(rotation.w),
        }

        scale := rl.Vector3 {
            f32(rl.GetRandomValue(100, 2000)) / 1000.0,
            f32(rl.GetRandomValue(100, 2000)) / 1000.0,
            f32(rl.GetRandomValue(100, 2000)) / 1000.0,
        }

        scales[i] = {
            r3d.PackFloat16(scale.x),
            r3d.PackFloat16(scale.y),
            r3d.PackFloat16(scale.z),
        }

        colors[i] = rl.ColorFromHSV(
            f32(rl.GetRandomValue(0, 360000)) / 1000.0,
            1.0,
            1.0,
        )
    }

    r3d.UnmapInstances(instances, {.POSITION, .ROTATION, .SCALE, .COLOR})

    // Create directional light
    light := r3d.CreateDirLight({0, -1, 0}, rl.WHITE, 1.0)

    // Setup camera
    camera: rl.Camera3D = {
        position = {0, 2, 2},
        target   = {0, 0, 0},
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
                r3d.PushLight(light)
                r3d.DrawMeshInstanced(mesh, material, instances, INSTANCE_COUNT)
            r3d.End()

            rl.DrawFPS(10, 10)
        rl.EndDrawing()
    }

    // Cleanup
    r3d.UnloadInstanceBuffer(instances)
    r3d.UnloadMaterial(material)
    r3d.UnloadMesh(mesh)
}
