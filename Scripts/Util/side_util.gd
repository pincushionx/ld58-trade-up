
class_name SideUtil

static func get_opposite_side(side : Constants.SIDE) -> Constants.SIDE:
	match side:
		Constants.SIDE.TOP: return Constants.SIDE.BOTTOM
		Constants.SIDE.BOTTOM: return Constants.SIDE.TOP
		Constants.SIDE.LEFT: return Constants.SIDE.RIGHT
		Constants.SIDE.RIGHT: return Constants.SIDE.LEFT
	return side

static func get_side_index(side : Constants.SIDE) -> int:
	match side:
		Constants.SIDE.TOP: return Constants.SIDE_INDEX.TOP
		Constants.SIDE.BOTTOM: return Constants.SIDE_INDEX.BOTTOM
		Constants.SIDE.LEFT: return Constants.SIDE_INDEX.LEFT
		Constants.SIDE.RIGHT: return Constants.SIDE_INDEX.RIGHT
	return -1
	
static func get_side_vector_offset(side : Constants.SIDE) -> Vector2i:
	match side:
		Constants.SIDE.TOP: return Vector2i.UP
		Constants.SIDE.BOTTOM: return Vector2i.DOWN
		Constants.SIDE.LEFT: return Vector2i.LEFT
		Constants.SIDE.RIGHT: return Vector2i.RIGHT
	return Vector2i()
