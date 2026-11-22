class_name DigSite
extends Node2D

signal digs_left_changed(digs_left: int)
signal run_ended
signal artifact_found(artifact: Artifact, cell: Vector2i)

# The side-panel layout in main.tscn assumes a 256 px grid, so this isn't exported yet.
const GRID_SIZE := Vector2i(8, 8)
const TILE_SCENE := preload("res://scenes/tile.tscn")

@export var dig_limit := 12
@export var artifacts_per_run := 10

var grid: DigGrid

var _tiles: Dictionary[Vector2i, Tile] = {}


func _ready() -> void:
	grid = DigGrid.new(GRID_SIZE.x, GRID_SIZE.y, dig_limit)
	grid.bury(Artifact.load_all(), artifacts_per_run)
	_spawn_tiles()
	_print_burial_map()


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
	if not grid.dig(cell):
		return
	var artifact := grid.artifact_at(cell)
	_tiles[cell].set_dug(artifact != null)
	# Emitted before run_ended, so a find on the last dig is reported while the run is still on.
	if artifact:
		artifact_found.emit(artifact, cell)
	digs_left_changed.emit(grid.digs_left())
	if grid.digs_left() == 0:
		run_ended.emit()


func _spawn_tiles() -> void:
	for y in grid.height:
		for x in grid.width:
			var cell := Vector2i(x, y)
			var tile := TILE_SCENE.instantiate() as Tile
			tile.position = cell_to_local(cell)
			add_child(tile)
			_tiles[cell] = tile


# TEMP (feature 6): shows where artifacts are buried, for testing discovery (7) and the hint (8).
# Remove when feature 8 is done.
func _print_burial_map() -> void:
	var finds: PackedStringArray = []
	print("Burial map (X = artifact):")
	for y in grid.height:
		var row := ""
		for x in grid.width:
			var artifact := grid.artifact_at(Vector2i(x, y))
			row += "X " if artifact else ". "
			if artifact:
				finds.append("  (%d, %d) %s" % [x, y, artifact.name])
		print("  " + row)
	print("\n".join(finds))
