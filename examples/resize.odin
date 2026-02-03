package resize

import rl "vendor:raylib"
import "core:fmt"
import r3d "../r3d"

get_aspect_mode_name :: proc(mode: r3d.AspectMode) -> cstring {
    switch mode {
    case .EXPAND: return "EXPAND"
    case .KEEP:   return "KEEP"
    }
    return "UNKNOWN"
}

get_upscale_mode_name :: proc(mode: r3d.UpscaleMode) -> cstring {
    switch mode {
    case .NEAREST: return "NEAREST"
    case .LINEAR:  return "LINEAR"
    case .BICUBIC: return "BICUBIC"
    case .LANCZOS: return "LANCZOS"
    }
    return "UNKNOWN"
}

main :: proc() {
    // Initialize window
    rl.InitWindow(800, 450, "[r3d] - Resize example")
    defer rl.CloseWindow()
    rl.SetWindowState({.WINDOW_RESIZABLE})
    rl.SetTargetFPS(60)

    // Initialize R3D
    r3d.Init(rl.GetScreenWidth(), rl.GetScreenHeight())
    defer r3d.Close()

    // Create sphere mesh and materials
    sphere := r3d.GenMeshSphere(0.5, 64, 64)
    defer r3d.UnloadMesh(sphere)
    materials: [5]r3d.Material
    for i in 0..<5 {
        materials[i] = r3d.GetDefaultMaterial()
        materials[i].albedo.color = rl.ColorFromHSV(f32(i) / 5 * 330, 1.0, 1.0)
    }

    // Setup directional light
    light := r3d.CreateLight(.DIR)
    r3d.SetLightDirection(light, {0, 0, -1})
    r3d.SetLightActive(light, true)

    // Setup camera
    camera: rl.Camera3D = {
        position = {0, 2, 2},
        target = {0, 0, 0},
        up = {0, 1, 0},
        fovy = 60,
    }

    // Current blit state
    aspect: r3d.AspectMode = .EXPAND
    upscale: r3d.UpscaleMode = .NEAREST

    // Main loop
    for !rl.WindowShouldClose()
    {
        rl.UpdateCamera(&camera, rl.CameraMode.ORBITAL)

        // Toggle aspect keep
        if rl.IsKeyPressed(.R) {
            aspect = r3d.AspectMode((int(aspect) + 1) % 2)
            r3d.SetAspectMode(aspect)
        }

        // Toggle linear filtering
        if rl.IsKeyPressed(.F) {
            upscale = r3d.UpscaleMode((int(upscale) + 1) % 4)
            r3d.SetUpscaleMode(upscale)
        }

        rl.BeginDrawing()
            rl.ClearBackground(rl.BLACK)

            // Draw spheres
            r3d.Begin(camera)
                for i in 0..<5 {
                    r3d.DrawMesh(sphere, materials[i], {f32(i) - 2, 0, 0}, 1.0)
                }
            r3d.End()

            // Draw info
            rl.DrawText(
                fmt.ctprintf("Resize mode: %s", get_aspect_mode_name(aspect)),
                10, 10, 20, rl.RAYWHITE,
            )
            rl.DrawText(
                fmt.ctprintf("Filter mode: %s", get_upscale_mode_name(upscale)),
                10, 40, 20, rl.RAYWHITE,
            )

        rl.EndDrawing()
    }
}
