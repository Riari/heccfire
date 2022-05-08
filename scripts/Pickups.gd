extends Spatial

func _ready():
	var player = get_node("../Player")
	for node in get_children():
		node.connect("picked_up", player, "on_pickup")
