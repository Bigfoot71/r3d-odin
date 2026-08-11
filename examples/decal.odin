package decal

import rl "vendor:raylib"
import r3d "../r3d"
import "core:math"

main :: proc() {
    // Initialize window
    rl.InitWindow(1152, 648, "[r3d] - Decal example")
    defer rl.CloseWindow()
    rl.SetTargetFPS(60)

    // Initialize R3D
    r3d.Init(rl.GetScreenWidth(), rl.GetScreenHeight())
    defer r3d.Close()

    // Create meshes
    plane := r3d.GenMeshPlane(5.0, 5.0, 1, 1)
    sphere := r3d.GenMeshSphere(0.5, 64, 64)
    cylinder := r3d.GenMeshCylinder(0.5, 1, 64)
    material := r3d.GetDefaultMaterial()
    material.albedo.color = rl.GRAY

    // Create decal
    decal := r3d.DECAL_BASE
    r3d.SetTextureFilter(.BILINEAR)
    decal.albedo = r3d.LoadAlbedoMap("./resources/images/decal.png", rl.WHITE)
    decal.normal = r3d.LoadNormalMap("./resources/images/decal_normal.png", 1.0)
    decal.normalThreshold = 45.0
    decal.fadeWidth = 20.0

    // Create data for instanced drawing
    instances := r3d.LoadInstanceBuffer(3, {.POSITION})
    positions := cast([^]rl.Vector3)r3d.MapInstances(instances, {.POSITION}, false)
    positions[0] = {-1.25, 0, 1}
    positions[1] = { 0,    0, 1}
    positions[2] = { 1.25, 0, 1}
    r3d.UnmapInstances(instances, {.POSITION})

    // Setup environment
    env := r3d.GetEnvironment()
    env.ambient.color = {10, 10, 10, 255}

    // Create light
    light := r3d.CreateDirLight({0.5, -1, -0.5}, rl.WHITE, 1.0)
    shadow := r3d.LoadShadowMap(.DIR)

    // Setup camera
    camera: rl.Camera3D = {
        position = {0, 3, 3},
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
                r3d.PushLightEx(light, shadow, false)

                r3d.DrawMesh(plane, material, {0, 0, 0}, 1.0)
                r3d.DrawMesh(sphere, material, {-1, 0.5, -1}, 1.0)
                r3d.DrawMeshEx(cylinder, material, {1, 0.5, -1}, rl.QuaternionFromEuler(0, 0, math.PI/2), {1, 1, 1})

                r3d.DrawDecal(decal, {-1, 1, -1}, 1.0)
                r3d.DrawDecalEx(decal, {1, 0.5, -0.5}, rl.QuaternionFromEuler(math.PI/2, 0, 0), {1.25, 1.25, 1.25})
                r3d.DrawDecalInstanced(decal, instances, 3)
            r3d.End()

        rl.EndDrawing()
    }

    // Cleanup
    r3d.UnloadMesh(plane)
    r3d.UnloadMesh(sphere)
    r3d.UnloadMesh(cylinder)
    r3d.UnloadMaterial(material)
    r3d.UnloadDecalMaps(decal)
}
