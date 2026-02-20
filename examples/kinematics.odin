package kinematics

import rl "vendor:raylib"
import "core:math"
import r3d "../r3d"

GRAVITY :: -15.0
MOVE_SPEED :: 5.0
JUMP_FORCE :: 8.0

capsule_center :: proc(caps: r3d.Capsule) -> rl.Vector3 {
    return (caps.start + caps.end) * 0.5
}

box_center :: proc(box: rl.BoundingBox) -> rl.Vector3 {
    return (box.min + box.max) * 0.5
}

main :: proc() {
    rl.InitWindow(800, 450, "[r3d] - Kinematics Example")
    defer rl.CloseWindow()
    rl.SetTargetFPS(60)

    r3d.Init(rl.GetScreenWidth(), rl.GetScreenHeight())
    defer r3d.Close()
    r3d.SetTextureFilter(.ANISOTROPIC_8X)

    sky := r3d.GenProceduralSky(1024, r3d.PROCEDURAL_SKY_BASE)
    ambient := r3d.GenAmbientMap(sky, {.ILLUMINATION, .REFLECTION})
    env := r3d.GetEnvironment()
    env.background.sky = sky
    env.ambient._map = ambient

    light := r3d.CreateLight(.DIR)
    r3d.SetLightDirection(light, {-1, -1, -1})
    r3d.SetLightRange(light, 16.0)
    r3d.SetLightActive(light, true)
    r3d.EnableShadow(light)
    r3d.SetShadowDepthBias(light, 0.005)

    // Load materials
    baseAlbedo := r3d.LoadAlbedoMap("./resources/images/placeholder.png", rl.WHITE)

    groundMat := r3d.GetDefaultMaterial()
    groundMat.uvScale = {250.0, 250.0}
    groundMat.albedo = baseAlbedo

    slopeMat := r3d.GetDefaultMaterial()
    slopeMat.albedo.color = {255, 255, 0, 255}
    slopeMat.albedo.texture = baseAlbedo.texture

    // Ground
    groundMesh := r3d.GenMeshPlane(1000, 1000, 1, 1)
    defer r3d.UnloadMesh(groundMesh)
    groundBox: rl.BoundingBox = {min = {-500, -1, -500}, max = {500, 0, 500}}

    // Slope obstacle
    slopeMeshData := r3d.GenMeshDataSlope(2, 2, 2, {0, 1, -1})
    defer r3d.UnloadMeshData(slopeMeshData)
    slopeMesh := r3d.LoadMesh(.TRIANGLES, slopeMeshData, nil, .STATIC_MESH)
    defer r3d.UnloadMesh(slopeMesh)
    slopeTransform := rl.MatrixTranslate(0, 1, 5)

    // Player capsule
    capsule: r3d.Capsule = {start = {0, 0.5, 0}, end = {0, 1.5, 0}, radius = 0.5}
    capsMesh := r3d.GenMeshCapsule(0.5, 1.0, 64, 32)
    defer r3d.UnloadMesh(capsMesh)
    velocity: rl.Vector3 = {0, 0, 0}

    // Camera
    cameraAngle: f32 = 0.0
    cameraPitch: f32 = 30.0
    camera: rl.Camera3D = {
        position = {0, 5, 5},
        target = capsule_center(capsule),
        up = {0, 1, 0},
        fovy = 60,
    }

    rl.DisableCursor()

    for !rl.WindowShouldClose()
    {
        dt := rl.GetFrameTime()

        // Camera rotation
        mouseDelta := rl.GetMouseDelta()
        cameraAngle -= mouseDelta.x * 0.15
        cameraPitch = clamp(cameraPitch + mouseDelta.y * 0.15, -7.5, 80.0)

        // Movement input relative to camera
        dx := i32(rl.IsKeyDown(.A)) - i32(rl.IsKeyDown(.D))
        dz := i32(rl.IsKeyDown(.W)) - i32(rl.IsKeyDown(.S))
        
        moveInput: rl.Vector3 = {0, 0, 0}
        if dx != 0 || dz != 0 {
            angleRad := cameraAngle * rl.DEG2RAD
            right := rl.Vector3{math.cos_f32(angleRad), 0, -math.sin_f32(angleRad)}
            forward := rl.Vector3{math.sin_f32(angleRad), 0, math.cos_f32(angleRad)}
            moveInput = rl.Vector3Normalize(right * f32(dx) + forward * f32(dz))
        }

        // Check grounded
        isGrounded := r3d.IsCapsuleGroundedBox(capsule, 0.01, groundBox, nil) ||
                      r3d.IsCapsuleGroundedMesh(capsule, 0.3, slopeMeshData, slopeTransform, nil)

        // Jump and apply gravity
        if isGrounded && rl.IsKeyPressed(.SPACE) do velocity.y = JUMP_FORCE
        if !isGrounded do velocity.y += GRAVITY * dt
        else if velocity.y < 0 do velocity.y = 0

        // Calculate total movement
        movement := moveInput * MOVE_SPEED * dt
        movement.y = velocity.y * dt

        // Apply movement with collision
        movement = r3d.SlideCapsuleMesh(capsule, movement, slopeMeshData, slopeTransform, nil)
        capsule.start = capsule.start + movement
        capsule.end = capsule.end + movement

        // Ground clamp
        if capsule.start.y < 0.5 {
            correction := 0.5 - capsule.start.y
            capsule.start.y += correction
            capsule.end.y += correction
            velocity.y = 0
        }

        // Update camera position
        target := capsule_center(capsule)
        pitchRad := cameraPitch * rl.DEG2RAD
        angleRad := cameraAngle * rl.DEG2RAD
        camera.position = {
            target.x - math.sin_f32(angleRad) * math.cos_f32(pitchRad) * 5.0,
            target.y + math.sin_f32(pitchRad) * 5.0,
            target.z - math.cos_f32(angleRad) * math.cos_f32(pitchRad) * 5.0,
        }
        camera.target = target

        rl.BeginDrawing()
            rl.ClearBackground(rl.BLACK)
            r3d.Begin(camera)
                r3d.DrawMeshPro(slopeMesh, slopeMat, slopeTransform)
                r3d.DrawMesh(groundMesh, groundMat, {0, 0, 0}, 1.0)
                r3d.DrawMesh(capsMesh, r3d.GetDefaultMaterial(), capsule_center(capsule), 1.0)
            r3d.End()
            rl.DrawFPS(10, 10)
            rl.DrawText(
                isGrounded ? "GROUNDED" : "AIRBORNE",
                10, rl.GetScreenHeight() - 30, 20,
                isGrounded ? rl.LIME : rl.YELLOW,
            )
        rl.EndDrawing()
    }
}
