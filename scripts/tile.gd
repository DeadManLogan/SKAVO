class_name Tile
extends Node2D

const SIZE := 32
const SHADE_VARIATION := 0.08

@export var base_color := Color("#a0805a")

var _color: Color


func _ready() -> void:
	_color = base_color
	_color.v *= randf_range(1.0 - SHADE_VARIATION, 1.0 + SHADE_VARIATION)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(SIZE, SIZE)), _color)
