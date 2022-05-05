extends Area

export(String, "AMMO_BLASTER") var pickup_type = "AMMO_BLASTER"
export var pickup_amount = 10
export var cooldown_time = 5
export var cooldown_color = Color(0.5, 0.5, 0.5, 0.5)

onready var mesh_containers = {
	"AMMO_BLASTER": $Types/BlasterAmmo
}

var origin
var active = true
var cooldown_timer = cooldown_time
var mesh_container: Node
var meshes = []
var cooldown_material = SpatialMaterial.new()

signal picked_up

func _ready():
	origin = self.global_transform.origin

	for n in mesh_containers.values():
		n.hide()

	mesh_container = mesh_containers[pickup_type]
	mesh_container.show()
	cooldown_material.flags_transparent = true
	cooldown_material.albedo_color = cooldown_color

	for n in mesh_container.get_children():
		if n is MeshInstance:
			meshes.append(n)

func _process(delta):
	self.rotate_y(delta)
	self.global_transform.origin.y = origin.y + (cos(OS.get_ticks_msec() / 300.0) / 10.0)

	if !active:
		if cooldown_timer <= 0:
			set_active(true)
			cooldown_timer = cooldown_time
		else:
			cooldown_timer -= delta

func set_active(is_active: bool):
	active = is_active
	for mesh in meshes:
		mesh.material_override = null if is_active else cooldown_material

func on_body_entered(node: Node):
	if active && node.get_meta("type") == "player":
		set_active(false)
		emit_signal("picked_up", node, pickup_type, pickup_amount)
