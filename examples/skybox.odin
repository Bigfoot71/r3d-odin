package skybox

import rl "vendor:raylib"
import r3d "../r3d"

main :: proc() {
    // Initialize window
    rl.InitWindow(800, 450, "[r3d] - Skybox example")
    defer rl.CloseWindow()
    rl.SetTargetFPS(60)

    // Initialize R3D
    r3d.Init(rl.GetScreenWidth(), rl.GetScreenHeight())
    defer r3d.Close()

    // Create sphere mesh
    sphere := r3d.GenMeshSphere(0.5, 32, 64)
    defer r3d.UnloadMesh(sphere)

    // Define procedural skybox parameters
    skyParams := r3d.CUBEMAP_SKY_BASE
    skyParams.groundEnergy = 2.0
    skyParams.skyEnergy = 2.0
    skyParams.sunEnergy = 2.0

    // Load and generate skyboxes
    skyProcedural := r3d.GenCubemapSky(512, skyParams)
    defer r3d.UnloadCubemap(skyProcedural)
    skyPanorama := r3d.LoadCubemap("./resources/panorama/sky.png", .AUTO_DETECT)
    defer r3d.UnloadCubemap(skyPanorama)

    // Generate ambient maps
    ambientProcedural := r3d.GenAmbientMap(skyProcedural, {.ILLUMINATION, .REFLECTION})
    defer r3d.UnloadAmbientMap(ambientProcedural)
    ambientPanorama := r3d.GenAmbientMap(skyPanorama, {.ILLUMINATION, .REFLECTION})
    defer r3d.UnloadAmbientMap(ambientPanorama)

    // Set default sky/ambient maps
    env := r3d.GetEnvironment()
    env.background.sky = skyPanorama
    env.ambient._map = ambientPanorama

    // Set tonemapping
    env.tonemap.mode = .AGX

    // Setup camera
    camera: rl.Camera3D = {
        position = {0, 0, 10},
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

            env := r3d.GetEnvironment()
            if rl.IsMouseButtonPressed(.LEFT) {
                if env.background.sky.texture == skyPanorama.texture {
                    env.background.sky = skyProcedural
                    env.ambient._map = ambientProcedural
                } else {
                    env.background.sky = skyPanorama
                    env.ambient._map = ambientPanorama
                }
            }

            // Draw sphere grid
            r3d.Begin(camera)
                for x in 0..=8 {
                    for y in 0..=8 {
                        material := r3d.GetDefaultMaterial()
                        material.orm.roughness = rl.Remap(f32(y), 0.0, 8.0, 0.0, 1.0)
                        material.orm.metalness = rl.Remap(f32(x), 0.0, 8.0, 0.0, 1.0)
                        r3d.DrawMesh(sphere, material, {f32(x - 4) * 1.25, f32(y - 4) * 1.25, 0.0}, 1.0)
                    }
                }
            r3d.End()

        rl.EndDrawing()
    }
}
