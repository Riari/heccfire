extends KinematicBody

var gravity = -30
var was_on_floor = true
export var max_speed = 12
export var max_air_speed = 10
export var mouse_sensitivity = 0.002  # radians/pixel

const SWAY_SPEED_FACTOR = 120.0  # higher is slower
const SWAY_INTENSITY_FACTOR = 20.0  # higher is less intense

onready var head = $Head
onready var hand = $Head/Hand
onready var camera = $Head/Camera
onready var weapon_viewport = $Head/WeaponViewportContainer/WeaponViewport
onready var weapon_cam = $Head/WeaponViewportContainer/WeaponViewport/WeaponCam
onready var weapon_muzzle = $Head/WeaponMuzzle
onready var weapon_fire_audio = $Head/WeaponMuzzle/WeaponFire

export (PackedScene) var Bullet
export var recoil_intensity = 0.04

var hand_origin
var hand_rotation

var velocity = Vector3()

enum Weapon {
	BLASTER
}

var ammo = {
	Weapon.BLASTER: 0
}

var current_weapon = Weapon.BLASTER

signal ammo_changed

func _ready():
	on_size_changed()
	get_tree().get_root().connect("size_changed", self, "on_size_changed")

	hand_origin = hand.transform.origin
	hand_rotation = hand.rotation
	
	weapon_viewport.world = get_world()

	set_ammo(Weapon.BLASTER, 30)
	set_meta("type", "player")

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func on_size_changed():
	weapon_viewport.size = get_viewport().size

func get_input():
	if Input.is_action_just_pressed("alt_fire"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	var input_dir = Vector3()
	if Input.is_action_pressed("move_forward"):
		input_dir += -global_transform.basis.z
	if Input.is_action_pressed("move_backward"):
		input_dir += global_transform.basis.z
	if Input.is_action_pressed("strafe_left"):
		input_dir += -global_transform.basis.x
	if Input.is_action_pressed("strafe_right"):
		input_dir += global_transform.basis.x
	if Input.is_action_pressed("jump"):
		input_dir += global_transform.basis.y

	return input_dir.normalized()

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, -1.2, 1.2)

func _process(_delta):
	weapon_cam.global_transform = camera.global_transform

	if Input.is_action_just_pressed("fire") && ammo[current_weapon] > 0:
		var b = Bullet.instance()
		get_parent().add_child(b)
		b.transform = weapon_muzzle.global_transform
		b.rotate_x(rand_range(-0.03, 0.03))
		b.rotate_y(rand_range(-0.03, 0.03))
		b.velocity = -b.transform.basis.z * b.muzzle_velocity
		hand.transform.origin.z += recoil_intensity
		hand.rotate_x(recoil_intensity * 2.0)
		weapon_fire_audio.play()
		remove_ammo(Weapon.BLASTER, 1)

func _physics_process(delta):
	if is_on_floor():
		var desired_velocity = get_input() * max_speed
		velocity = desired_velocity
		if velocity.y == 0:
			velocity.y += gravity * delta
	else:
		var desired_velocity = get_input() * max_air_speed
		velocity.x = desired_velocity.x
		velocity.y += gravity * delta
		velocity.z = desired_velocity.z

	velocity = move_and_slide(velocity, Vector3.UP, true)

	if is_on_floor() && (velocity.x != 0 || velocity.y != 0):
		var t = OS.get_ticks_msec() / SWAY_SPEED_FACTOR
		hand.transform.origin.x = lerp(hand.transform.origin.x, hand_origin.x + cos(t + PI) / SWAY_INTENSITY_FACTOR, delta * 10)
		hand.transform.origin.y = lerp(hand.transform.origin.y, hand_origin.y + cos(t * 2.0) / SWAY_INTENSITY_FACTOR, delta * 10)
		hand.transform.origin.z = lerp(hand.transform.origin.z, hand_origin.z, delta * 10)
	elif hand.transform.origin != hand_origin:
		hand.transform.origin = lerp(hand.transform.origin, hand_origin, delta * 10)

	hand.rotation.x = lerp(hand.rotation.x, hand_rotation.x, delta * 10)

func on_pickup(node: Node, type: String, amount: int):
	if node == self:
		var weapon
		match type:
			"AMMO_BLASTER":
				weapon = Weapon.BLASTER

		add_ammo(weapon, amount)

func set_ammo(weapon: int, amount: int):
	ammo[weapon] = amount
	if weapon == current_weapon:
		emit_signal("ammo_changed", ammo[weapon])

func add_ammo(weapon: int, amount: int):
	set_ammo(weapon, ammo[weapon] + amount)

func remove_ammo(weapon: int, amount: int):
	set_ammo(weapon, ammo[weapon] - amount)
