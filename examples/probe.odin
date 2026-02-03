package probe

import rl "vendor:raylib"
import "core:math"
import r3d "../r3d"

main :: proc() {
    // Initialize window
    rl.InitWindow(800, 450, "[r3d] - Probe example")
    defer rl.CloseWindow()
    rl.SetTargetFPS(60)

    // Initialize R3D
    r3d.Init(rl.GetScreenWidth(), rl.GetScreenHeight())
    defer r3d.Close()

    // Setup environment sky
    cubemap := r3d.LoadCubemap("./resources/panorama/indoor.png", .AUTO_DETECT)
    defer r3d.UnloadCubemap(cubemap)
    env := r3d.GetEnvironment()
    env.background.skyBlur = 0.3
    env.background.sky = cubemap

    // Setup environment ambient
    ambientMap := r3d.GenAmbientMap(cubemap, {.ILLUMINATION, .REFLECTION})
    defer r3d.UnloadAmbientMap(ambientMap)
    env.ambient._map = ambientMap

    // Setup tonemapping
    env.tonemap.mode = .FILMIC

    // Create meshes
    plane := r3d.GenMeshPlane(30, 30, 1, 1)
    defer r3d.UnloadMesh(plane)
    sphere := r3d.GenMeshSphere(0.5, 64, 64)
    defer r3d.UnloadMesh(sphere)
    material := r3d.GetDefaultMaterial()

    // Create light
    light := r3d.CreateLight(.SPOT)
    r3d.LightLookAt(light, {0, 10, 5}, {0, 0, 0})
    r3d.SetLightActive(light, true)
    r3d.EnableShadow(light)

    // Create probe
    probe := r3d.CreateProbe({.ILLUMINATION, .REFLECTION})
    r3d.SetProbePosition(probe, {0, 1, 0})
    r3d.SetProbeShadows(probe, true)
    r3d.SetProbeFalloff(probe, 0.5)
    r3d.SetProbeActive(probe, true)

    // Setup camera
    camera: rl.Camera3D = {
        position = {0, 3.0, 6.0},
        target = {0, 0.5, 0},
        up = {0, 1, 0},
        fovy = 60,
    }

    // Main loop
    for !rl.WindowShouldClose()
    {
        rl.UpdateCamera(&camera, rl.CameraMode.ORBITAL)

        rl.BeginDrawing()
            rl.ClearBackground(rl.RAYWHITE)

            r3d.Begin(camera)

                material.orm.roughness = 0.5
                material.orm.metalness = 0.0
                r3d.DrawMesh(plane, material, {0, 0, 0}, 1.0)

                for i in -1..=1 {
                    material.orm.roughness = math.abs(f32(i)) * 0.4
                    material.orm.metalness = 1.0 - math.abs(f32(i))
                    r3d.DrawMesh(sphere, material, {f32(i) * 3.0, 1.0, 0}, 2.0)
                }

            r3d.End()

        rl.EndDrawing()
    }
}
