package sprite

import rl "vendor:raylib"
import "core:math"
import r3d "../r3d"

get_texcoord_scale_offset :: proc(xFrameCount: int, yFrameCount: int, currentFrame: f32) -> (uvScale: rl.Vector2, uvOffset: rl.Vector2) {
    uvScale.x = 1.0 / f32(xFrameCount)
    uvScale.y = 1.0 / f32(yFrameCount)

    frameIndex := int(currentFrame + 0.5) % (xFrameCount * yFrameCount)
    frameX := frameIndex % xFrameCount
    frameY := frameIndex / xFrameCount

    uvOffset.x = f32(frameX) * uvScale.x
    uvOffset.y = f32(frameY) * uvScale.y

    return
}

main :: proc() {
    // Initialize window
    rl.InitWindow(1152, 648, "[r3d] - Sprite example")
    defer rl.CloseWindow()
    rl.SetTargetFPS(60)

    // Initialize R3D
    r3d.Init(rl.GetScreenWidth(), rl.GetScreenHeight())
    defer r3d.Close()
    r3d.SetTextureFilter(.POINT)
    r3d.SetTextureWrap(.REPEAT)

    // Set background/ambient color
    env := r3d.GetEnvironment()
    env.background.color = {102, 191, 255, 255}
    env.ambient.color = {10, 19, 25, 255}
    env.tonemap.mode = .FILMIC

    // Create ground mesh and material
    meshGround := r3d.GenMeshPlane(200, 200, 1, 1)
    matGround := r3d.GetDefaultMaterial()
    matGround.albedo.color = rl.GREEN

    // Create sprite mesh and material
    meshSprite := r3d.GenMeshQuad(1.0, 1.0, 1, 1, {0, 0, 1})
    meshSprite.shadowCastMode = .ON_DOUBLE_SIDED

    matSprite := r3d.GetDefaultMaterial()
    matSprite.albedo = r3d.LoadAlbedoMap("./resources/images/spritesheet.png", rl.WHITE)
    matSprite.billboardMode = .Y_AXIS

    // Create light
    light := r3d.CreateSpotLight({0, 10, 10}, {0, -1, -1}, 32.0, rl.WHITE, 1.0)
    shadow := r3d.LoadShadowMap(.SPOT)

    // Setup camera
    camera: rl.Camera3D = {
        position = {0, 2, 5},
        target   = {0, 0.5, 0},
        up       = {0, 1, 0},
        fovy     = 45,
    }

    // Bird data
    birdPos: rl.Vector3 = {0, 0.5, 0}
    birdDirX: f32 = 1.0

    // Main loop
    for !rl.WindowShouldClose() {
        // Update bird position
        birdPrev := birdPos
        time := f32(rl.GetTime())
        birdPos.x = 2.0 * math.sin_f32(time)
        birdPos.y = 1.0 + math.cos_f32(time * 4.0) * 0.5
        birdDirX = (birdPos.x - birdPrev.x >= 0.0) ? 1.0 : -1.0

        // Update sprite UVs
        // We multiply by the sign of the X direction to invert the uvScale.x
        currentFrame := 10.0 * time
        matSprite.uvScale, matSprite.uvOffset = get_texcoord_scale_offset(
            int(4 * birdDirX),
            1,
            currentFrame,
        )

        rl.BeginDrawing()
            rl.ClearBackground(rl.RAYWHITE)

            // Draw scene
            r3d.Begin(camera)
                r3d.PushLightEx(light, shadow, true)
                r3d.DrawMesh(meshGround, matGround, {0, -0.5, 0}, 1.0)
                r3d.DrawMesh(meshSprite, matSprite, {birdPos.x, birdPos.y, 0}, 1.0)
            r3d.End()

        rl.EndDrawing()
    }

    // Cleanup
    r3d.UnloadMaterial(matSprite)
    r3d.UnloadMesh(meshSprite)
    r3d.UnloadMesh(meshGround)
}
