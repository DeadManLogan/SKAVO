class_name Tile
extends Node2D

const SIZE := 32
const SHADE_VARIATION := 0.08

@export var base_color := Color("#a0805a")
@export var dug_color := Color("#4a3628")

var _dirt_color: Color
var _is_dug := false


func _ready() -> void:
	_dirt_color = base_color
	_dirt_color.v *= randf_range(1.0 - SHADE_VARIATION, 1.0 + SHADE_VARIATION)


func set_dug() -> void:
	_is_dug = true
	queue_redraw()


func _draw() -> void:
	# The color is chosen at draw time, so set_dug() works even if called before _ready().
	var color := dug_color if _is_dug else _dirt_color
	draw_rect(Rect2(Vector2.ZERO, Vector2(SIZE, SIZE)), color)
