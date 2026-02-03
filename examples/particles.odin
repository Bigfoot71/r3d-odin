package particles

import rl "vendor:raylib"
import "core:math"
import r3d "../r3d"

MAX_PARTICLES :: 4096

Particle :: struct {
    pos: rl.Vector3,
    vel: rl.Vector3,
    life: f32,
}

main :: proc() {
    // Initialize window
    rl.InitWindow(800, 450, "[r3d] - Particles example")
    defer rl.CloseWindow()
    rl.SetTargetFPS(60)

    // Initialize R3D
    r3d.Init(rl.GetScreenWidth(), rl.GetScreenHeight())
    defer r3d.Close()

    // Set environment
    env := r3d.GetEnvironment()
    env.background.color = {4, 4, 4, 255}
    env.bloom.mode = .ADDITIVE

    // Generate a gradient as emission texture for our particles
    image := rl.GenImageGradientRadial(64, 64, 0.0, rl.WHITE, rl.BLACK)
    texture := rl.LoadTextureFromImage(image)
    defer rl.UnloadTexture(texture)
    rl.UnloadImage(image)

    // Generate a quad mesh for our particles
    mesh := r3d.GenMeshQuad(0.25, 0.25, 1, 1, {0, 0, 1})
    defer r3d.UnloadMesh(mesh)

    // Setup particle material
    material := r3d.GetDefaultMaterial()
    defer r3d.UnloadMaterial(material)
    material.billboardMode = .FRONT
    material.blendMode = .ADDITIVE
    material.albedo.texture = r3d.GetBlackTexture()
    material.emission.color = {255, 0, 0, 255}
    material.emission.texture = texture
    material.emission.energy = 1.0

    // Create particle instance buffer
    instances := r3d.LoadInstanceBuffer(MAX_PARTICLES, {.POSITION})
    defer r3d.UnloadInstanceBuffer(instances)

    // Setup camera
    camera: rl.Camera3D = {
        position = {-7, 7, -7},
        target = {0, 1, 0},
        up = {0, 1, 0},
        fovy = 60.0,
        projection = .PERSPECTIVE,
    }

    // CPU buffer for storing particles
    particles: [MAX_PARTICLES]Particle
    positions: [MAX_PARTICLES]rl.Vector3
    particleCount: i32 = 0

    for !rl.WindowShouldClose()
    {
        dt := rl.GetFrameTime()
        rl.UpdateCamera(&camera, rl.CameraMode.ORBITAL)

        // Spawn particles
        for i in 0..<10 {
            if particleCount < MAX_PARTICLES {
                angle := f32(rl.GetRandomValue(0, 360)) * rl.DEG2RAD
                particles[particleCount].pos = {0, 0, 0}
                particles[particleCount].vel = {
                    math.cos_f32(angle) * f32(rl.GetRandomValue(20, 40)) / 10.0,
                    f32(rl.GetRandomValue(60, 80)) / 10.0,
                    math.sin_f32(angle) * f32(rl.GetRandomValue(20, 40)) / 10.0,
                }
                particles[particleCount].life = 1.0
                particleCount += 1
            }
        }

        // Update particles
        alive: i32 = 0
        for i in 0..<particleCount {
            particles[i].vel.y -= 9.81 * dt
            particles[i].pos.x += particles[i].vel.x * dt
            particles[i].pos.y += particles[i].vel.y * dt
            particles[i].pos.z += particles[i].vel.z * dt
            particles[i].life -= dt * 0.5
            if particles[i].life > 0 {
                positions[alive] = particles[i].pos
                particles[alive] = particles[i]
                alive += 1
            }
        }
        particleCount = alive

        r3d.UploadInstances(instances, {.POSITION}, 0, particleCount, raw_data(positions[:]))

        rl.BeginDrawing()
            r3d.Begin(camera)
                r3d.DrawMeshInstanced(mesh, material, instances, particleCount)
            r3d.End()
            rl.DrawFPS(10, 10)
        rl.EndDrawing()
    }
}
