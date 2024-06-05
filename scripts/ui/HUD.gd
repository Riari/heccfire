extends Control

@onready var health = $Panel/Health/Count
@onready var ammo = $Panel/Ammo/Count

@export var pickup_animation_time = 0.6

var health_amount = 0
var ammo_amount = 0

func _process(delta: float):
	ease_back(health, delta)
	ease_back(ammo, delta)

func embiggen(label: RichTextLabel):
	label.scale.x = 2.0
	label.scale.y = 2.0

func ease_back(label: RichTextLabel, delta: float):
	if label.scale.x > 1.0:
		label.scale.x -= ease(delta / pickup_animation_time, 0.5)
		label.scale.y -= ease(delta / pickup_animation_time, 0.5)

func on_health_changed(amount: int):
	if amount > health_amount:
		embiggen(health)
	
	health_amount = amount
	health.text = str(health_amount)

func on_ammo_changed(amount: int):
	if amount > ammo_amount:
		embiggen(ammo)

	ammo_amount = amount
	ammo.text = str(ammo_amount)

func on_pickup(node: Node, type: String, amount: int):
	$CrosshairContainer/PickupAudio.play()
