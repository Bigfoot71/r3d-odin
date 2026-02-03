package dof

import rl "vendor:raylib"
import "core:math/rand"
import "core:fmt"
import r3d "../r3d"

X_INSTANCES :: 10
Y_INSTANCES :: 10
INSTANCE_COUNT :: X_INSTANCES * Y_INSTANCES

main :: proc() {
    // Initialize window
    rl.InitWindow(800, 450, "[r3d] - DoF example")
    defer rl.CloseWindow()
    rl.SetTargetFPS(60)

    // Initialize R3D with FXAA
    r3d.Init(rl.GetScreenWidth(), rl.GetScreenHeight())
    defer r3d.Close()
    r3d.SetAntiAliasing(.FXAA)

    // Configure depth of field and background
    env := r3d.GetEnvironment()
    env.background.color = rl.BLACK
    env.dof.mode = .ENABLED
    env.dof.focusPoint = 2.0
    env.dof.focusScale = 3.0
    env.dof.maxBlurSize = 20.0
    env.dof.debugMode = false

    // Create directional light
    light := r3d.CreateLight(.DIR)
    r3d.SetLightDirection(light, {0, -1, 0})
    r3d.SetLightActive(light, true)

    // Create sphere mesh and default material
    meshSphere := r3d.GenMeshSphere(0.2, 64, 64)
    defer r3d.UnloadMesh(meshSphere)
    matDefault := r3d.GetDefaultMaterial()

    // Generate instance matrices and colors
    spacing: f32 = 0.5
    offsetX := (X_INSTANCES * spacing) / 2.0
    offsetZ := (Y_INSTANCES * spacing) / 2.0
    idx := 0
    instances := r3d.LoadInstanceBuffer(INSTANCE_COUNT, {.POSITION, .COLOR})
    defer r3d.UnloadInstanceBuffer(instances)
    positions := cast([^]rl.Vector3)r3d.MapInstances(instances, {.POSITION})
    colors := cast([^]rl.Color)r3d.MapInstances(instances, {.COLOR})
    for x in 0..<X_INSTANCES {
        for y in 0..<Y_INSTANCES {
            positions[idx] = {f32(x) * spacing - offsetX, 0, f32(y) * spacing - offsetZ}
            colors[idx] = {u8(rand.uint32() % 256), u8(rand.uint32() % 256), u8(rand.uint32() % 256), 255}
            idx += 1
        }
    }
    r3d.UnmapInstances(instances, {.POSITION, .COLOR})

    // Setup camera
    camDefault: rl.Camera3D = {
        position = {0, 2, 2},
        target = {0, 0, 0},
        up = {0, 1, 0},
        fovy = 60,
    }

    // Main loop
    for !rl.WindowShouldClose()
    {
        delta := rl.GetFrameTime()

        // Rotate camera
        rotation := rl.MatrixRotate(camDefault.up, 0.1 * delta)
        view := camDefault.position - camDefault.target
        view = rl.Vector3Transform(view, rotation)
        camDefault.position = camDefault.target + view

        // Adjust DoF based on mouse
        mousePos := rl.GetMousePosition()
        focusPoint := 0.5 + (5.0 - (mousePos.y / f32(rl.GetScreenHeight())) * 5.0)
        focusScale := 0.5 + (5.0 - (mousePos.x / f32(rl.GetScreenWidth())) * 5.0)
        env := r3d.GetEnvironment()
        env.dof.focusPoint = focusPoint
        env.dof.focusScale = focusScale

        mouseWheel := rl.GetMouseWheelMove()
        if mouseWheel != 0.0 {
            env.dof.maxBlurSize = env.dof.maxBlurSize + mouseWheel * 0.1
        }

        if rl.IsKeyPressed(.F1) {
            env.dof.debugMode = !env.dof.debugMode
        }

        rl.BeginDrawing()
            rl.ClearBackground(rl.BLACK)

            // Render scene
            r3d.Begin(camDefault)
                r3d.DrawMeshInstanced(meshSphere, matDefault, instances, INSTANCE_COUNT)
            r3d.End()

            // Display DoF values
            dofText := fmt.ctprintf(
                "Focus Point: %.2f\nFocus Scale: %.2f\nMax Blur Size: %.2f\nDebug Mode: %v",
                env.dof.focusPoint, env.dof.focusScale,
                env.dof.maxBlurSize, env.dof.debugMode,
            )
            rl.DrawText(dofText, 10, 30, 20, {255, 255, 255, 127})

            // Display instructions
            rl.DrawText(
                "F1: Toggle Debug Mode\nScroll: Adjust Max Blur Size\nMouse Left/Right: Shallow/Deep DoF\nMouse Up/Down: Adjust Focus Point Depth",
                300, 10, 20, {255, 255, 255, 127},
            )

            // Display FPS
            fpsText := fmt.ctprintf("FPS: %d", rl.GetFPS())
            rl.DrawText(fpsText, 10, 10, 20, {255, 255, 255, 127})

        rl.EndDrawing()
    }
}
