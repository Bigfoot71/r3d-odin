/* r3d_platform.odin -- Platform definitions.
 *
 * Copyright (c) 2025-2026 Le Juez Victor
 *
 * This software is provided 'as-is', without any express or implied warranty.
 * For conditions of distribution and use, see accompanying LICENSE file.
 */
package r3d

import rl "vendor:raylib"

when ODIN_OS == .Windows {
    foreign import lib {
        "windows/libr3d.a",
        "vendor:raylib/windows/raylib.lib",
        "windows/libassimp.a",
        "vendor:zlib/libz.lib",
    }
} else when ODIN_OS == .Linux {
    foreign import lib {
        "linux/libr3d.a",
        "vendor:raylib/linux/libraylib.a",
        "linux/libassimp.a",
        "system:z",
        "system:stdc++",
        "system:dl",
        "system:pthread",
        "system:m",
    }
} else when ODIN_OS == .Darwin {
    foreign import lib {
        "darwin/libr3d.a",
        "vendor:raylib/macos/libraylib.a",
        "darwin/libassimp.a",
        "system:z",
        "system:c++",
    }
}

