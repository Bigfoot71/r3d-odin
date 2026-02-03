package bloom

import rl "vendor:raylib"
import "core:math"
import r3d "../r3d"

main :: proc() {
    // Initialize window
    rl.InitWindow(800, 450, "[r3d] - Bloom example")
    defer rl.CloseWindow()
    rl.SetTargetFPS(60)

    // Initialize R3D
    r3d.Init(rl.GetScreenWidth(), rl.GetScreenHeight())
    defer r3d.Close()

    // Setup bloom and tonemapping
    env := r3d.GetEnvironment()
    env.tonemap.mode = .ACES
    env.bloom.mode = .MIX
    env.bloom.levels = 1.0

    // Set background
    env.background.color = rl.BLACK

    // Create cube mesh and material
    cube := r3d.GenMeshCube(1.0, 1.0, 1.0)
    defer r3d.UnloadMesh(cube)
    material := r3d.GetDefaultMaterial()
    hueCube: f32 = 0.0
    material.emission.color = rl.ColorFromHSV(hueCube, 1.0, 1.0)
    material.emission.energy = 1.0
    material.albedo.color = rl.BLACK

    // Setup camera
    camera: rl.Camera3D = {
        position = {0, 3.5, 5},
        target   = {0, 0, 0},
        up       = {0, 1, 0},
        fovy     = 60,
    }

    // Main loop
    for !rl.WindowShouldClose()
    {
        delta := rl.GetFrameTime()
        rl.UpdateCamera(&camera, rl.CameraMode.ORBITAL)

        // Change cube color
        if rl.IsKeyDown(.C) {
            hueCube = math.wrap(hueCube + 45.0 * delta, 360)
            material.emission.color = rl.ColorFromHSV(hueCube, 1.0, 1.0)
        }

        // Adjust bloom parameters
        env := r3d.GetEnvironment()
        
        intensityDir := i32(is_key_down_delay(.RIGHT)) - i32(is_key_down_delay(.LEFT))
        adjust_bloom_param(&env.bloom.intensity, intensityDir, 0.01, 0.0, math.F32_MAX)

        radiusDir := i32(is_key_down_delay(.UP)) - i32(is_key_down_delay(.DOWN))
        adjust_bloom_param(&env.bloom.filterRadius, radiusDir, 0.1, 0.0, math.F32_MAX)

        levelDir := i32(rl.IsMouseButtonDown(.RIGHT)) - i32(rl.IsMouseButtonDown(.LEFT))
        adjust_bloom_param(&env.bloom.levels, levelDir, 0.01, 0.0, 1.0)

        // Cycle bloom mode
        if rl.IsKeyPressed(.SPACE) {
            env.bloom.mode = r3d.Bloom((int(env.bloom.mode) + 1) % (int(r3d.Bloom.SCREEN) + 1))
        }

        rl.BeginDrawing()
            rl.ClearBackground(rl.RAYWHITE)

            r3d.Begin(camera)
                r3d.DrawMesh(cube, material, {0, 0, 0}, 1.0)
            r3d.End()

            // Draw bloom info
            draw_text_right(rl.TextFormat("Mode: %s", get_bloom_mode_name()), 10, 20, rl.LIME)
            draw_text_right(rl.TextFormat("Intensity: %.2f", env.bloom.intensity), 40, 20, rl.LIME)
            draw_text_right(rl.TextFormat("Filter Radius: %.2f", env.bloom.filterRadius), 70, 20, rl.LIME)
            draw_text_right(rl.TextFormat("Levels: %.2f", env.bloom.levels), 100, 20, rl.LIME)

        rl.EndDrawing()
    }
}

is_key_down_delay :: proc(key: rl.KeyboardKey) -> bool {
    return rl.IsKeyPressedRepeat(key) || rl.IsKeyPressed(key)
}

get_bloom_mode_name :: proc() -> cstring {
    modes := [?]cstring{"Disabled", "Mix", "Additive", "Screen"}
    env := r3d.GetEnvironment()
    mode := int(env.bloom.mode)
    return mode >= 0 && mode < len(modes) ? modes[mode] : "Unknown"
}

draw_text_right :: proc(text: cstring, y: i32, fontSize: i32, color: rl.Color) {
    width := rl.MeasureText(text, fontSize)
    rl.DrawText(text, rl.GetScreenWidth() - width - 10, y, fontSize, color)
}

adjust_bloom_param :: proc(param: ^f32, direction: i32, step: f32, min: f32, max: f32) {
    if direction != 0 {
        param^ = clamp(param^ + f32(direction) * step, min, max)
    }
}
