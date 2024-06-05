extends Node3D

func _ready():
	var player = get_node("../Player")
	for node in get_children():
		node.connect("picked_up", Callable(player, "on_pickup"))
