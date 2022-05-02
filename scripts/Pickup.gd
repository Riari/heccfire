extends Area

var origin

export(String, "AMMO_BLASTER") var pickup_type = "AMMO_BLASTER"
export var pickup_amount = 10

onready var type_nodes = {
	"AMMO_BLASTER": $Types/BlasterAmmo
}

signal picked_up

func _ready():
	origin = self.global_transform.origin
	type_nodes[pickup_type].show()

func _process(delta):
	self.rotate_y(delta)
	self.global_transform.origin.y = origin.y + (cos(OS.get_ticks_msec() / 300.0) / 10.0)

func on_body_entered(node: Node):
	if node.get_meta("type") == "player":
		emit_signal("picked_up", node, pickup_type, pickup_amount)
		queue_free()
