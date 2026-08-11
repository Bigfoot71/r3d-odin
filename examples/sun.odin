package sun

import rl "vendor:raylib"
import r3d "../r3d"

X_INSTANCES :: 50
Y_INSTANCES :: 50
INSTANCE_COUNT :: X_INSTANCES * Y_INSTANCES

main :: proc() {
    // Initialize window
    rl.InitWindow(1152, 648, "[r3d] - Sun example")
    defer rl.CloseWindow()
    rl.SetTargetFPS(60)

    // Initialize R3D
    r3d.Init(rl.GetScreenWidth(), rl.GetScreenHeight())
    defer r3d.Close()
    r3d.SetAntiAliasingMode(.FXAA)

    // Create meshes and material
    plane := r3d.GenMeshPlane(1000, 1000, 1, 1)
    sphere := r3d.GenMeshSphere(0.35, 16, 32)
    material := r3d.GetDefaultMaterial()

    // Create transforms for instanced spheres
    instances := r3d.LoadInstanceBuffer(INSTANCE_COUNT, {.POSITION})
    positions := cast([^]rl.Vector3)r3d.MapInstances(instances, {.POSITION}, false)
    spacing: f32 = 1.5
    offsetX := (X_INSTANCES * spacing) / 2.0
    offsetZ := (Y_INSTANCES * spacing) / 2.0
    idx := 0
    for x in 0..<X_INSTANCES {
        for y in 0..<Y_INSTANCES {
            positions[idx] = {f32(x) * spacing - offsetX, 0, f32(y) * spacing - offsetZ}
            idx += 1
        }
    }
    r3d.UnmapInstances(instances, {.POSITION})

    // Setup environment
    skybox := r3d.GenProceduralSky(1024, r3d.PROCEDURAL_SKY_BASE)
    env := r3d.GetEnvironment()
    env.background.sky = skybox

    ambientMap := r3d.GenAmbientMap(skybox, {.ILLUMINATION, .REFLECTION})
    env.ambient._map = ambientMap

    // Setup lights with shadows
    light := r3d.CreateDirLight({-1, -1, -1}, rl.WHITE, 1.0)
    shadow := r3d.LoadShadowMap(.DIR)
    shadow.softness = 3.0

    // Setup camera
    camera: rl.Camera3D = {
        position = {0, 1, 0},
        target   = {1, 1.25, 1},
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
                r3d.PushLightEx(light, shadow, true)
                r3d.DrawMesh(plane, material, {0, -0.5, 0}, 1.0)
                r3d.DrawMeshInstanced(sphere, material, instances, INSTANCE_COUNT)
            r3d.End()
        rl.EndDrawing()
    }

    // Cleanup
    r3d.UnloadInstanceBuffer(instances)
    r3d.UnloadMaterial(material)
    r3d.UnloadMesh(sphere)
    r3d.UnloadMesh(plane)
}
