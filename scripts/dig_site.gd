class_name DigSite
extends Node2D

const GRID_SIZE := Vector2i(8, 8)
const TILE_SCENE := preload("res://scenes/tile.tscn")

var grid: DigGrid

var _tiles: Dictionary[Vector2i, Tile] = {}


func _ready() -> void:
	grid = DigGrid.new(GRID_SIZE.x, GRID_SIZE.y)
	_spawn_tiles()


# _unhandled_input, not _input, so UI on top (the found-artifact popup later) gets the click first and blocks it.
func _unhandled_input(event: InputEvent) -> void:
	var mouse_event := event as InputEventMouseButton
	if mouse_event and mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
		# Use the click's own position, transformed into DigSite space, rather than polling the mouse separately.
		var local_event := make_input_local(mouse_event) as InputEventMouseButton
		_try_dig(local_to_cell(local_event.position))


func cell_to_local(cell: Vector2i) -> Vector2:
	return Vector2(cell * Tile.SIZE)


func local_to_cell(local_pos: Vector2) -> Vector2i:
	# floor, not truncation, so positions just left of or above the grid map to -1 and fail is_in_bounds.
	return Vector2i((local_pos / Tile.SIZE).floor())


func _try_dig(cell: Vector2i) -> void:
	if grid.dig(cell):
		_tiles[cell].set_dug()


func _spawn_tiles() -> void:
	for y in grid.height:
		for x in grid.width:
			var cell := Vector2i(x, y)
			var tile := TILE_SCENE.instantiate() as Tile
			tile.position = cell_to_local(cell)
			add_child(tile)
			_tiles[cell] = tile
