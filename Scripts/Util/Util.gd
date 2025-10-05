extends Node

class_name Util

static func get_degrees_difference(from : float, to : float):
	from = fposmod(from, 360)
	to = fposmod(to, 360)

	var distance1 : float
	var distance2 : float

	if to > from:
		distance1 = to - from
		distance2 = - ((from + 360) - to)
	elif from > to:
		distance1 = - (from - to)	
		distance2 = ((to + 360) - from)
	else:
		return 0

	if abs(distance1) > abs(distance2):
		return distance2
	return distance1

static func rotate_to(from : float, to : float, degrees : float):
	var diff : float = Util.get_degrees_difference(from, to)
	
	if abs(diff) < degrees:
		return to
	else:
		return from + degrees * signf(diff)

static func InMask(value : int, mask : int):
	return value & mask >  0
