# Project setup

Godot 4.6, GDScript only, Compatibility renderer (`gl_compatibility`). All values below are in `project.godot`. Change them in Project > Project Settings, not by hand-editing the file.

## Display

| Setting | Value | Why |
|---|---|---|
| Viewport size | 640x360 | Low base resolution for pixel art, 16:9, scales by whole numbers to 720p (2x), 1080p (3x) and 1440p (4x) |
| Window override | 1280x720 | The editor run window opens at 2x so the game isn't tiny during development |
| Stretch mode | `viewport` | The game renders at 640x360 and then the whole image is scaled up, so pixels stay square and sprites never land on sub-pixel positions |
| Stretch scale mode | `integer` | Only whole-number scales, so no pixel is drawn wider than its neighbor. At window sizes in between, the result is letterboxed instead of blurred or distorted |

Consequence of `viewport` mode: the default font and any UI text are also rendered at 640x360 and scaled, so text looks chunky. That's expected. A pixel font in the art pass fixes it.

## Rendering

| Setting | Value | Why |
|---|---|---|
| Renderer | Compatibility | 2D only, widest hardware support, and it can export to web |
| Default texture filter | Nearest | Pixel art stays crisp instead of being bilinear-blurred when scaled |

## Grid sizing
Tiles are 32x32 px, so the 8x8 grid is 256x256 px. That leaves 360 - 256 = 104 px of vertical room and 384 px of horizontal room in the viewport for the hint, dig counter and title. 32 px is big enough for artifact sprites to read clearly.

## Git
- `.gitignore` excludes `.godot/` (the editor's import cache, rebuilt automatically).
- `.gitattributes` normalizes text files to LF.
- `*.uid` files (for example `dig_grid.gd.uid`) **are** committed. Godot 4.4+ uses them to keep references stable when files move.
- Remote: `https://github.com/DeadManLogan/SKAVO.git`, branch `main`. One commit per finished feature (or task), then push.
