extends Spatial

func _ready():
	var hud = get_node("../HUD")
	var player = get_node("../Player")
	for node in get_children():
		node.connect("picked_up", hud, "on_pickup")
		node.connect("picked_up", player, "on_pickup")
