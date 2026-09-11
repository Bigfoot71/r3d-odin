/* r3d_camera.odin -- R3D Camera Module.
 *
 * Copyright (c) 2025-2026 Le Juez Victor
 *
 * This software is provided "as-is", without any express or implied warranty.
 * For conditions of distribution and use, see the accompanying LICENSE file.
 */
package r3d

import rl "vendor:raylib"

when ODIN_OS == .Windows {
    foreign import lib {
        "windows/r3d.lib",
    }
} else when ODIN_OS == .Linux {
    foreign import lib {
        "linux/libr3d.a",
    }
} else when ODIN_OS == .Darwin {
    foreign import lib {
        "macos/libr3d.a",
    }
}

/**
 * @brief Projection mode used by an R3D camera.
 */
Projection :: enum u32 {
    PERSPECTIVE  = 0, ///< Perspective projection.
    ORTHOGRAPHIC = 1, ///< Orthographic projection.
}

/**
 * @brief rl.Quaternion-based 3D camera used by R3D.
 *
 * Unlike raylib's rl.Camera3D, this camera stores its orientation directly as a
 * quaternion instead of using a target/up pair. It also stores near/far clipping
 * planes and a layer mask used to filter visible renderables.
 */
Camera :: struct {
    position:   rl.Vector3,    ///< Camera world-space position.
    rotation:   rl.Quaternion, ///< Camera world-space orientation.
    fovy:       f64,        ///< Vertical field of view in degrees for perspective projection; vertical size for orthographic projection.
    nearPlane:  f64,        ///< Distance to the near clipping plane.
    farPlane:   f64,        ///< Distance to the far clipping plane.
    cullMask:   Layer,      ///< Camera visibility layer mask.
    projection: Projection, ///< Camera projection mode.
}

@(default_calling_convention="c", link_prefix="R3D_")
foreign lib {
    /**
     * @brief Creates an R3D camera from a raylib camera.
     *
     * The camera position, orientation, field of view and projection mode are
     * derived from the given raylib camera.
     *
     * Since raylib's rl.Camera3D does not store near/far clipping planes or layer
     * masks, the near/far planes are initialized from the current rlgl culling
     * distances, while the layer mask is set to the default R3D camera layer mask.
     *
     * @param camera Raylib camera to convert.
     *
     * @return Converted R3D camera.
     */
    CameraFromRL :: proc(camera: rl.Camera3D) -> Camera ---

    /**
     * @brief Converts an R3D camera to a raylib camera.
     *
     * The raylib target/up vectors are derived from the camera quaternion.
     * Near/far clipping planes and layer masks are not represented by rl.Camera3D.
     */
    CameraToRL :: proc(camera: Camera) -> rl.Camera3D ---

    /**
     * @brief Sets the camera orientation so it looks at a target point.
     */
    CameraLookAt :: proc(camera: ^Camera, target: rl.Vector3, up: rl.Vector3) ---

    /**
     * @brief Returns the camera forward direction in world space.
     */
    GetCameraForward :: proc(camera: Camera) -> rl.Vector3 ---

    /**
     * @brief Returns the camera right direction in world space.
     */
    GetCameraRight :: proc(camera: Camera) -> rl.Vector3 ---

    /**
     * @brief Returns the camera up direction in world space.
     */
    GetCameraUp :: proc(camera: Camera) -> rl.Vector3 ---

    /**
     * @brief Returns the camera view matrix.
     */
    GetCameraView :: proc(camera: Camera) -> rl.Matrix ---

    /**
     * @brief Returns the camera projection matrix.
     */
    GetCameraProj :: proc(camera: Camera, aspect: f64) -> rl.Matrix ---

    /**
     * @brief Returns the combined view-projection matrix.
     */
    GetCameraViewProj :: proc(camera: Camera, aspect: f64) -> rl.Matrix ---

    /**
     * @brief Moves the camera in world space.
     */
    MoveCamera :: proc(camera: ^Camera, delta: rl.Vector3) ---

    /**
     * @brief Moves the camera in local space.
     */
    MoveCameraLocal :: proc(camera: ^Camera, delta: rl.Vector3) ---

    /**
     * @brief Rotates the camera using a quaternion.
     */
    CameraRotate :: proc(camera: ^Camera, rotation: rl.Quaternion) ---

    /**
     * @brief Rotates the camera around its local X axis.
     */
    CameraPitch :: proc(camera: ^Camera, angle: f32) ---

    /**
     * @brief Rotates the camera around its local Y axis.
     */
    CameraYaw :: proc(camera: ^Camera, angle: f32) ---

    /**
     * @brief Rotates the camera around its local Z axis.
     */
    CameraRoll :: proc(camera: ^Camera, angle: f32) ---

    /**
     * @brief Replaces the camera culling mask.
     */
    SetCameraCullMask :: proc(camera: ^Camera, cullMask: Layer) ---

    /**
     * @brief Enables one or more layers in the camera culling mask.
     */
    EnableCameraCullLayers :: proc(camera: ^Camera, layerMask: Layer) ---

    /**
     * @brief Disables one or more layers from the camera culling mask.
     */
    DisableCameraCullLayers :: proc(camera: ^Camera, layerMask: Layer) ---

    /**
     * @brief Toggles one or more layers in the camera culling mask.
     */
    ToggleCameraCullLayers :: proc(camera: ^Camera, layerMask: Layer) ---

    /**
     * @brief Checks whether at least one object layer is visible to the camera.
     */
    IsCameraLayerVisible :: proc(camera: Camera, layerMask: Layer) -> bool ---
}

