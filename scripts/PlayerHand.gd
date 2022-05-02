extends Spatial

var mouse_moved = 0

export var sway_threshold = 5
export var sway_lerp = 5
export var sway_left : Vector3
export var sway_right : Vector3
export var sway_normal : Vector3

func _input(event):
	if event is InputEventMouseMotion:
		mouse_moved = -event.relative.x

func _process(delta):
	var sway
	if mouse_moved > sway_threshold:
		sway = sway_left
	elif mouse_moved < -sway_threshold:
		sway = sway_right
	else:
		sway = sway_normal

	rotation = rotation.linear_interpolate(sway, sway_lerp * delta)
