class_name DigSite
extends Node2D

const GRID_SIZE := Vector2i(8, 8)
const TILE_SCENE := preload("res://scenes/tile.tscn")

var grid: DigGrid


func _ready() -> void:
	grid = DigGrid.new(GRID_SIZE.x, GRID_SIZE.y)
	_spawn_tiles()


func cell_to_local(cell: Vector2i) -> Vector2:
	return Vector2(cell * Tile.SIZE)


func local_to_cell(local_pos: Vector2) -> Vector2i:
	# floor, not truncation, so positions just left of or above the grid map to -1 and fail is_in_bounds.
	return Vector2i((local_pos / Tile.SIZE).floor())


func _spawn_tiles() -> void:
	for y in grid.height:
		for x in grid.width:
			var tile := TILE_SCENE.instantiate() as Tile
			tile.position = cell_to_local(Vector2i(x, y))
			add_child(tile)
