class_name DigGrid
extends RefCounted

var width: int
var height: int
var dig_limit: int

# Used as a set: a cell is dug if it's a key. Undug cells aren't stored.
var _dug: Dictionary[Vector2i, bool] = {}
# Per-run burial: cell -> artifact. The same Artifact can be buried in several cells.
var _buried: Dictionary[Vector2i, Artifact] = {}


func _init(p_width: int, p_height: int, p_dig_limit: int) -> void:
	width = p_width
	height = p_height
	dig_limit = p_dig_limit


func is_in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < width and cell.y >= 0 and cell.y < height


func is_dug(cell: Vector2i) -> bool:
	return _dug.has(cell)


# Every dug cell used one dig, so the count comes from _dug instead of a separate counter.
func digs_left() -> int:
	return dig_limit - _dug.size()


# Returns false when nothing was dug, so the caller only reacts to real digs.
func dig(cell: Vector2i) -> bool:
	if digs_left() <= 0 or not is_in_bounds(cell) or is_dug(cell):
		return false
	_dug[cell] = true
	return true


func artifact_at(cell: Vector2i) -> Artifact:
	return _buried.get(cell)


# Buries `count` artifacts in distinct random undug cells. Each one is an independent
# random pick from `artifacts`, so duplicates are allowed.
func bury(artifacts: Array[Artifact], count: int) -> void:
	if artifacts.is_empty():
		push_warning("No artifacts to bury.")
		return
	var cells := _undug_cells()
	if count > cells.size():
		push_warning("Asked to bury %d artifacts but only %d cells are free." % [count, cells.size()])
	cells.shuffle()
	for i in mini(count, cells.size()):
		var artifact: Artifact = artifacts.pick_random()
		_buried[cells[i]] = artifact


func _undug_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for y in height:
		for x in width:
			var cell := Vector2i(x, y)
			if not is_dug(cell):
				cells.append(cell)
	return cells
