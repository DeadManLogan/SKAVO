# SKAVO art brief: artifact sprites

For the pixel-art agent. This brief covers what the game needs from the art. Everything about how it's built stays in the game repo.

## The game
SKAVO is a small 2D top-down archaeology game set on a **Roman-era Mediterranean hillside**, around the 1st century BC to the 3rd century AD. The player digs tiles on an 8x8 grid of dirt to find 10 buried artifacts. When one is found, a popup shows its sprite with its name, era and a short real-history blurb. The aim is to make players curious enough to look up the era afterward, so the objects should feel real, used and old, not like fantasy loot.

## Fixed constraints (expensive to change later)
- **Canvas:** 32x32 px per artifact, the same size as one grid tile.
- **Background:** transparent. Bake in no background, ground or drop shadow.
- **Alpha:** fully opaque or fully transparent pixels only. Show translucency (glass) with color, not with partial alpha.
- **Edges:** no anti-aliasing against a background color. The game's colors will change, and a halo blended into today's colors would show later.
- **Export:** PNG at 1x (100%). Don't export upscaled: the game scales with nearest-neighbor filtering at whole-number multiples, so every source pixel shows. The popup will probably show sprites at 2x or 3x.
- **Files:** one PNG per artifact, named exactly as listed below. A sprite sheet is fine as a working file, but deliver the separate PNGs as well. They go into `art/artifacts/` in the game repo.
- **Framing:** fill roughly 24–28 px of the canvas, with a small margin. Each object fills the frame whatever its real size, the way icons do, so a coin and a jar handle read at the same size.
- **Consistency:** the same light direction (top-left), outline rule and level of detail across all 10. Show each object from its most recognizable side, either flat-on or a slight 3/4 view, the way it would appear in a museum catalog.

## Provisional (expected to change)
The palette, UI and screen colors aren't decided yet. For now:
- Screen background: `#3b2f2a` (dark brown)
- Undug dirt tiles: about `#a0805a` (tan)
- Dug tiles: `#4a3628` (dark brown)

Make sure each sprite reads on both the dark browns and the tan. Dark bronze and lead objects will likely need an outline or rim light. Working in Aseprite's **indexed color mode** with a shared palette means a later palette change is a palette swap rather than repainting 10 sprites.

## Artifacts
| File | Artifact | What it looks like |
|---|---|---|
| `denarius.png` | Silver denarius | Small silver coin with a laureate emperor's head in profile. Worn, with a slightly irregular edge and dark grey toning in the recesses. |
| `oil_lamp.png` | Terracotta oil lamp | Mold-made orange-red clay lamp: a round body with a decorated, slightly sunken top and a filling hole, a nozzle with a wick hole at the front and a small handle at the back. |
| `amphora_handle.png` | Stamped amphora handle | Broken fragment of a big buff or pale-orange clay storage jar: a thick curved handle with a small rectangular maker's stamp and a bit of the neck attached, with rough broken edges. |
| `fibula.png` | Bronze fibula | Bow-shaped brooch that works like a safety pin: an arched bow, a coiled spring at one end, the pin, and a catch plate. Green-brown patina with a few bronze highlights. |
| `strigil.png` | Strigil | Bronze bathhouse scraper: a straight handle joined to a curved, spoon-like blade with a concave channel, roughly a J shape. Patina with worn bright edges. |
| `stylus.png` | Bronze stylus | Thin writing pen for wax tablets: a sharp point at one end and a flat spatula-shaped eraser at the other. Long and thin, so lay it diagonally. |
| `sigillata_sherd.png` | Terra sigillata sherd | Broken piece of a glossy, bright red-orange bowl, possibly with molded relief decoration such as an egg-and-dart border. The broken edges show the paler clay inside. |
| `sling_bullet.png` | Lead sling bullet | Almond-shaped lead slug, dull grey, sometimes with a raised inscription or symbol such as a thunderbolt. Low contrast, so it needs a rim light. |
| `unguentarium.png` | Glass unguentarium | Small perfume or oil bottle with a long narrow neck and a bulbous body. Pale blue-green glass with iridescent weathering patches. |
| `gaming_die.png` | Bone gaming die | Off-white to yellowish bone cube, slightly irregular, with ring-and-dot pips. Opposite faces usually add up to seven. |

## Coming later
Terrain tiles for the same hillside: undug dirt, which needs a few variants so the grid doesn't look tiled, and dug ground. They're also 32x32 and sit edge to edge with no gaps, so the edges must line up. The details will come in a separate brief.
