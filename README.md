# r3d-odin

<img align="left" src="https://github.com/Bigfoot71/r3d/blob/master/logo.png" width="100" hspace="20">
<br>
Odin binding for [r3d](https://github.com/Bigfoot71/r3d), a library that extends raylib's 3D capabilities with rendering, lighting, kinematics, mesh utilities, and more.
<br clear="left">

## Overview

This repository provides a complete Odin binding for `r3d`, automatically updated via GitHub Actions using [r3d-odin-bindgen](https://github.com/Bigfoot71/r3d-odin-bindgen).  
You can also clone the bindgen repo to generate bindings locally for modified versions of `r3d`.  

> [!NOTE]
> Examples in this repository are manually adapted. Skyboxes have been converted to PNG for compatibility with standard raylib builds, so visuals may be slightly simplified compared to the original `r3d` examples.

## Getting Started

- Include the `r3d` directory in your Odin project.
- Run your Odin project as usual.

```odin
package main

import rl "vendor:raylib"
import "r3d"

main :: proc() {
    rl.InitWindow(800, 600, "r3d quick start")
    defer rl.CloseWindow()
    rl.SetTargetFPS(60)

    r3d.Init(800, 600)
    defer r3d.Close()

    // Create scene objects
    mesh := r3d.GenMeshSphere(1.0, 16, 32)
    defer r3d.UnloadMesh(mesh)

    // Setup lighting
    light := r3d.CreateLight(.DIR)
    r3d.SetLightDirection(light, {-1, -1, -1})
    r3d.SetLightActive(light, true)

    // Camera setup
    camera: rl.Camera3D = {
        position = {3, 3, 3},
        target = {0, 0, 0},
        up = {0, 1, 0},
        fovy = 60.0,
        projection = .PERSPECTIVE
    };

    // Main loop
    for !rl.WindowShouldClose() {
        rl.UpdateCamera(&camera, .ORBITAL)
        rl.BeginDrawing()
        r3d.Begin(camera)
        r3d.DrawMesh(mesh, r3d.GetDefaultMaterial(), {}, 1.0)
        r3d.End()
        rl.EndDrawing()
    }
}
```

---

## License

Licensed under the **Zlib License** - see [LICENSE](LICENSE) for details.
