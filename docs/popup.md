# Found-artifact popup

When a dig finds an artifact, a window opens in the middle of the screen with the artifact's sprite, name, era and blurb. The game behind it is blurred and darkened and can't be clicked until **Close** is pressed.

## Flow
`DigSite.artifact_found(artifact, cell)` → `Main._on_dig_site_artifact_found` → `ArtifactPopup.show_artifact(artifact)`, which fills the fields and calls `show()`. Close's `pressed` signal → `_on_close_button_pressed` → `hide()`. The popup is one reused node: it's hidden in `main.tscn` and never freed.

## Scene (`scenes/artifact_popup.tscn`, `scripts/artifact_popup.gd`)
```
ArtifactPopup (ColorRect)        Full Rect, screen_blur shader, Mouse Filter = Stop, script
└── CenterContainer              Full Rect
    └── Card (PanelContainer)    the visible window, sized by its content
        └── MarginContainer      12 px on every side
            └── VBoxContainer    separation 8
                ├── Header (HBoxContainer)     separation 12
                │   ├── SpriteSlot (Control)   64x64
                │   │   ├── %SpritePlaceholder (ColorRect)  gold #d4a93a, shown while sprite is null
                │   │   └── %Sprite (TextureRect)           Ignore Size, Keep Aspect Centered
                │   └── Titles (VBoxContainer)  %NameLabel, %EraLabel
                ├── %BlurbLabel (Label)        autowrap Word (Smart), min width 424
                └── CloseButton (Button)       Shrink Center
```
- `%` nodes have **Access as Unique Name** on, so the script finds them as `%Sprite` and so on, regardless of their path in the scene.
- **The width comes from `BlurbLabel` alone** (424 + 2 × 12 margin = 448 px). An autowrapped Label in a container needs its own minimum width to wrap at (Godot warns otherwise), so it's the single place the width is set. The height follows the text. The longest blurb (`sigillata_sherd`, about 335 characters) wraps to about 7 lines, and the panel stays well inside 360 px.
- **Sprite slot:** 64x64 with Keep Aspect Centered shows a 32x32 sprite at 2x or a 64x64 sprite at 1x, so either answer to the open sprite-size question works. While `sprite` is `null` (until feature 10), the gold placeholder shows instead.
- The labels and the blurb in the scene contain test text (denarius, sigillata) for F6 previews. `show_artifact()` overwrites all of it.

## Blocking the dig site
The root `ColorRect` covers the whole screen with Mouse Filter = Stop. GUI gets clicks before `_unhandled_input`, so while the popup is visible, no click reaches `DigSite` and nothing is dug. No "popup open" flag is needed. See [architecture.md](architecture.md) (input). It also means a second find can't happen while the popup is open.

## Placement: `PopupLayer` (CanvasLayer)
The instance lives under `Main/PopupLayer`, not directly under `Main`. Under a `Node2D`, Full Rect resolves to 0x0, and the window ended up hanging off the top-left corner. See [architecture.md](architecture.md#screen-space-ui-goes-on-a-canvaslayer). Layer 1 also draws above the game regardless of tree order.

## Blur backdrop (`shaders/screen_blur.gdshader`)
A `canvas_item` shader on the root reads `hint_screen_texture` (everything drawn before it, which is the whole game on layer 0), box-blurs it and mixes in a tint. The Compatibility renderer doesn't generate mipmaps for the screen texture, so the usual `textureLod()` blur doesn't work. The shader takes explicit samples instead: a (2 × radius + 1)² grid, 49 samples at radius 3, which is cheap at 640x360.

| Uniform | Default | Effect |
|---|---|---|
| `radius` | 3 | Samples per side. More is smoother and costs more. |
| `spread` | 1.5 | Game pixels between samples. Higher is a wider blur for the same cost. |
| `tint` | black, alpha 0.4 | Colour mixed over the blur. Alpha is the strength. |

They're tuned on the ShaderMaterial in `artifact_popup.tscn` (Inspector → Material).

## Later
- **Text:** the labels use the default font and look soft at 2x. A pixel font comes with the art pass (see [project-setup.md](project-setup.md)).
- **Run-end summary (11):** a find on the last dig opens the popup and then `run_ended` fires while it's still open. A summary that appears right away would stack on top of the popup. It should wait until the popup closes, which would need a `closed` signal on `ArtifactPopup`. The `PopupLayer` + blur backdrop pattern can be reused for the summary.
