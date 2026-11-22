class_name Tile
extends Node2D

const SIZE := 32
const SHADE_VARIATION := 0.08
const MARKER_SIZE := 12

@export var base_color := Color("#a0805a")
@export var dug_color := Color("#4a3628")
@export var find_color := Color("#e0b040")

var _dirt_color: Color
var _is_dug := false
var _has_find := false


func _ready() -> void:
	_dirt_color = base_color
	_dirt_color.v *= randf_range(1.0 - SHADE_VARIATION, 1.0 + SHADE_VARIATION)


func set_dug(has_find: bool) -> void:
	_is_dug = true
	_has_find = has_find
	queue_redraw()


func _draw() -> void:
	# The color is chosen at draw time, so set_dug() works even if called before _ready().
	var color := dug_color if _is_dug else _dirt_color
	draw_rect(Rect2(Vector2.ZERO, Vector2(SIZE, SIZE)), color)
	if _has_find:
		# Placeholder marker until the art pass (feature 10).
		var offset := (SIZE - MARKER_SIZE) / 2.0
		draw_rect(Rect2(Vector2(offset, offset), Vector2(MARKER_SIZE, MARKER_SIZE)), find_color)
