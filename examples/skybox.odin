package skybox

import rl "vendor:raylib"
import r3d "../r3d"

main :: proc() {
    // Initialize window
    rl.InitWindow(1152, 648, "[r3d] - Skybox example")
    defer rl.CloseWindow()
    rl.SetTargetFPS(60)

    // Initialize R3D
    r3d.Init(rl.GetScreenWidth(), rl.GetScreenHeight())
    defer r3d.Close()

    // Create sphere mesh
    sphere := r3d.GenMeshSphere(0.5, 32, 64)

    // Define procedural skybox parameters
    skyParams := r3d.PROCEDURAL_SKY_BASE
    skyParams.groundEnergy = 2.0
    skyParams.skyEnergy = 2.0
    skyParams.sunEnergy = 2.0

    // Load a custom sky shader
    shader := r3d.LoadSkyShader("./resources/shaders/sky.glsl")
    color := rl.Vector3{0.0, 0.5, 0.0}
    r3d.SetSkyShaderUniform(shader, "u_color", &color)
    cells := [2]i32{10, 10}
    r3d.SetSkyShaderUniform(shader, "u_cells", &cells)
    line_px := f32(1.0)
    r3d.SetSkyShaderUniform(shader, "u_line_px", &line_px)

    // Load and generate skyboxes
    skyPanorama := r3d.LoadCubemap("./resources/panorama/sky.png", .AUTO_DETECT)
    skyProcedural := r3d.GenProceduralSky(1024, skyParams)
    skyCustom := r3d.GenCustomSky(512, shader)

    // Generate ambient maps
    ambientPanorama := r3d.GenAmbientMap(skyPanorama, {.ILLUMINATION, .REFLECTION})
    ambientProcedural := r3d.GenAmbientMap(skyProcedural, {.ILLUMINATION, .REFLECTION})
    ambientCustom := r3d.GenAmbientMap(skyCustom, {.ILLUMINATION, .REFLECTION})

    // Store skies/ambients
    backgrounds: [3]r3d.EnvBackground
    ambients: [3]r3d.EnvAmbient
    currentSky: i32 = 0

    for i in 0..<3 {
        backgrounds[i].energy = 1.0
        ambients[i].energy = 1.0
    }

    backgrounds[0].sky = skyPanorama
    backgrounds[1].sky = skyProcedural
    backgrounds[2].sky = skyCustom

    ambients[0]._map = ambientPanorama
    ambients[1]._map = ambientProcedural
    ambients[2]._map = ambientCustom

    // Set default sky/ambient maps
    env := r3d.GetEnvironment()
    env.background.sky = skyPanorama
    env.ambient._map = ambientPanorama

    // Set tonemapping
    env.tonemap.mode = .AGX

    // Setup camera
    camera: rl.Camera3D = {
        position = {0, 0, 10},
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

        currentSky += i32(rl.IsMouseButtonPressed(.RIGHT)) - i32(rl.IsMouseButtonPressed(.LEFT))
        currentSky = (currentSky + 3) % 3

        env.background = backgrounds[currentSky]
        env.ambient = ambients[currentSky]

        // Draw sphere grid
        r3d.Begin(camera)
            for x in 0..=8 {
                for y in 0..=8 {
                    material := r3d.MATERIAL_BASE
                    material.orm.roughness = rl.Remap(f32(y), 0.0, 8.0, 0.0, 1.0)
                    material.orm.metalness = rl.Remap(f32(x), 0.0, 8.0, 0.0, 1.0)
                    r3d.DrawMesh(sphere, material, {f32(x - 4) * 1.25, f32(y - 4) * 1.25, 0.0}, 1.0)
                }
            }
        r3d.End()

        rl.EndDrawing()
    }

    // Cleanup
    r3d.UnloadAmbientMap(ambientProcedural)
    r3d.UnloadAmbientMap(ambientPanorama)
    r3d.UnloadCubemap(skyProcedural)
    r3d.UnloadCubemap(skyPanorama)
    r3d.UnloadMesh(sphere)
}
