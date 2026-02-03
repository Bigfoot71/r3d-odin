package pbr

import rl "vendor:raylib"
import r3d "../r3d"

main :: proc() {
    // Initialize window
    rl.InitWindow(800, 450, "[r3d] - PBR example")
    defer rl.CloseWindow()
    rl.SetTargetFPS(60)

    // Initialize R3D
    r3d.Init(rl.GetScreenWidth(), rl.GetScreenHeight())
    defer r3d.Close()
    r3d.SetAntiAliasing(.FXAA)

    // Setup environment sky
    cubemap := r3d.LoadCubemap("./resources/panorama/indoor.png", .AUTO_DETECT)
    defer r3d.UnloadCubemap(cubemap)
    env := r3d.GetEnvironment()
    env.background.skyBlur = 0.775
    env.background.sky = cubemap

    // Setup environment ambient
    ambientMap := r3d.GenAmbientMap(cubemap, {.ILLUMINATION, .REFLECTION})
    defer r3d.UnloadAmbientMap(ambientMap)
    env.ambient._map = ambientMap

    // Setup bloom
    env.bloom.mode = .MIX
    env.bloom.intensity = 0.02

    // Setup tonemapping
    env.tonemap.mode = .FILMIC
    env.tonemap.exposure = 1.0
    env.tonemap.white = 4.0

    // Load model
    r3d.SetTextureFilter(.ANISOTROPIC_4X)
    model := r3d.LoadModel("./resources/models/DamagedHelmet.glb")
    defer r3d.UnloadModel(model, true)
    modelMatrix := rl.Matrix(1)
    modelScale: f32 = 1.0

    // Setup camera
    camera: rl.Camera3D = {
        position = {0, 0, 2.5},
        target = {0, 0, 0},
        up = {0, 1, 0},
        fovy = 60,
    }

    // Main loop
    for !rl.WindowShouldClose()
    {
        // Update model scale with mouse wheel
        modelScale = clamp(modelScale + rl.GetMouseWheelMove() * 0.1, 0.25, 2.5)

        // Rotate model with left mouse button
        if rl.IsMouseButtonDown(.LEFT) {
            mouseDelta := rl.GetMouseDelta()
            pitch := (mouseDelta.y * 0.005) / modelScale
            yaw   := (mouseDelta.x * 0.005) / modelScale
            rotate := rl.MatrixRotateXYZ({pitch, yaw, 0.0})
            modelMatrix = rotate * modelMatrix
        }

        rl.BeginDrawing()
            rl.ClearBackground(rl.RAYWHITE)
            r3d.Begin(camera)
                scale := rl.MatrixScale(modelScale, modelScale, modelScale)
                transform := scale * modelMatrix
                r3d.DrawModelPro(model, transform)
            r3d.End()
        rl.EndDrawing()
    }
}
