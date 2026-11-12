class_name DigGrid
extends RefCounted

var width: int
var height: int

# Used as a set: a cell is dug if it's a key. Undug cells aren't stored.
var _dug: Dictionary[Vector2i, bool] = {}


func _init(p_width: int, p_height: int) -> void:
	width = p_width
	height = p_height


func is_in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < width and cell.y >= 0 and cell.y < height


func is_dug(cell: Vector2i) -> bool:
	return _dug.has(cell)


# Returns false when nothing was dug, so the caller only reacts to real digs.
func dig(cell: Vector2i) -> bool:
	if not is_in_bounds(cell) or is_dug(cell):
		return false
	_dug[cell] = true
	return true
