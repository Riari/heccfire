extends Control

func _ready():
	get_node("../Player").connect("ammo_changed", self, "on_ammo_changed")

func on_ammo_changed(count: int):
	$AmmoCount.text = str(count)

func on_pickup(node: Node, type: String, amount: int):
	$CrosshairContainer/PickupAudio.play()
