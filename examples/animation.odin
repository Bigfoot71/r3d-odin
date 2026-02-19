package animation

import rl "vendor:raylib"
import r3d "../r3d"

main :: proc() {
    // Initialize window
    rl.InitWindow(800, 450, "[r3d] - Animation example")
    defer rl.CloseWindow()
    rl.SetTargetFPS(60)

    // Initialize R3D with FXAA
    r3d.Init(rl.GetScreenWidth(), rl.GetScreenHeight())
    defer r3d.Close()
    r3d.SetAntiAliasingMode(.FXAA)

    // Setup environment sky
    cubemap := r3d.LoadCubemap("./resources/panorama/indoor.png", .AUTO_DETECT)
    env := r3d.GetEnvironment()
    env.background.skyBlur = 0.3
    env.background.energy = 0.6
    env.background.sky = cubemap

    // Setup environment ambient
    ambientMap := r3d.GenAmbientMap(cubemap, {.ILLUMINATION})
    env.ambient._map = ambientMap
    env.ambient.energy = 0.25

    // Setup tonemapping
    env.tonemap.mode = .FILMIC
    env.tonemap.exposure = 1.5

    // Generate a ground plane and load the animated model
    plane := r3d.GenMeshPlane(10, 10, 1, 1)
    model := r3d.LoadModel("./resources/models/CesiumMan.glb")

    // Load animations
    modelAnims := r3d.LoadAnimationLib("./resources/models/CesiumMan.glb")
    modelPlayer := r3d.LoadAnimationPlayer(model.skeleton, modelAnims)

    // Setup animation playing
    r3d.SetAnimationWeight(&modelPlayer, 0, 1.0)
    r3d.SetAnimationLoop(&modelPlayer, 0, true)
    r3d.PlayAnimation(&modelPlayer, 0)

    // Create model instances
    instances := r3d.LoadInstanceBuffer(4, {.POSITION})
    positions := cast([^]rl.Vector3)r3d.MapInstances(instances, {.POSITION})
    for z in 0..<2 {
        for x in 0..<2 {
            positions[z*2 + x] = {f32(x) - 0.5, 0, f32(z) - 0.5}
        }
    }
    r3d.UnmapInstances(instances, {.POSITION})

    // Setup lights with shadows
    light := r3d.CreateLight(.DIR)
    r3d.SetLightDirection(light, {-1.0, -1.0, -1.0})
    r3d.SetLightActive(light, true)
    r3d.SetLightRange(light, 10.0)
    r3d.EnableShadow(light)

    // Setup camera
    camera: rl.Camera3D = {
        position = {0, 1.5, 3.0},
        target = {0, 0.75, 0.0},
        up = {0, 1, 0},
        fovy = 60
    }

    // Main loop
    for !rl.WindowShouldClose()
    {
        delta := rl.GetFrameTime()

        rl.UpdateCamera(&camera, rl.CameraMode.ORBITAL)
        r3d.UpdateAnimationPlayer(&modelPlayer, delta)

        rl.BeginDrawing()
            rl.ClearBackground(rl.RAYWHITE)
            r3d.Begin(camera)
                r3d.DrawMesh(plane, r3d.GetDefaultMaterial(), {0, 0, 0}, 1.0)
                r3d.DrawAnimatedModel(model, modelPlayer, {0, 0, 0}, 1.25)
                r3d.DrawAnimatedModelInstanced(model, modelPlayer, instances, 4)
            r3d.End()
        rl.EndDrawing()
    }

    // Cleanup
    r3d.UnloadAnimationPlayer(modelPlayer)
    r3d.UnloadAnimationLib(modelAnims)
    r3d.UnloadModel(model, true)
    r3d.UnloadMesh(plane)
}
