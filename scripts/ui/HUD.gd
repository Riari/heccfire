extends Control

export var ammo_count_animation_time = 0.6

var ammo_count = 0

func _ready():
	get_node("../Player").connect("ammo_changed", self, "on_ammo_changed")

func _process(delta):
	if $AmmoCount.rect_scale.x > 1.0:
		$AmmoCount.rect_scale.x -= ease(delta / ammo_count_animation_time, 0.5)
		$AmmoCount.rect_scale.y -= ease(delta / ammo_count_animation_time, 0.5)

func on_ammo_changed(count: int):
	if count > ammo_count:
		$AmmoCount.rect_scale.x = 2.0
		$AmmoCount.rect_scale.y = 2.0

	ammo_count = count
	$AmmoCount.text = str(ammo_count)

func on_pickup(node: Node, type: String, amount: int):
	$CrosshairContainer/PickupAudio.play()
