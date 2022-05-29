extends KinematicBody

export var max_speed = 16
export var max_air_speed = 16
export var acceleration = 10.0
export var mouse_sensitivity = 0.002  # radians/pixel
export (PackedScene) var Projectile
export var recoil_intensity = 0.04

const SWAY_SPEED = 120.0  # higher is slower
const SWAY_INTENSITY = 20.0  # higher is less intense
const HAND_MOTION_LERP_SPEED = 10.0  # higher is faster

onready var head = $Head
onready var hand = $Head/Hand
onready var camera = $Head/Camera
onready var weapon_viewport = $Head/WeaponViewportContainer/WeaponViewport
onready var weapon_cam = $Head/WeaponViewportContainer/WeaponViewport/WeaponCam
onready var weapon_muzzle = $Head/WeaponMuzzle
onready var weapon_fire_audio = $Head/WeaponMuzzle/WeaponFire
onready var jump_audio = $Jump

var gravity = -30
var weapon_accuracy = 0.03
var was_on_floor = true
var velocity = Vector3()
var hand_origin
var hand_rotation

enum Weapon {
	BLASTER
}

var ammo = {
	Weapon.BLASTER: 0
}

var ammo_cost = {
	Weapon.BLASTER: 1
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
	var input_dir = Vector3()
	if Input.is_action_pressed("move_forward"):
		input_dir += -global_transform.basis.z
	if Input.is_action_pressed("move_backward"):
		input_dir += global_transform.basis.z
	if Input.is_action_pressed("strafe_left"):
		input_dir += -global_transform.basis.x
	if Input.is_action_pressed("strafe_right"):
		input_dir += global_transform.basis.x
	if Input.is_action_just_released("jump"):
		input_dir += global_transform.basis.y
		jump_audio.play()

	return input_dir.normalized()

func _unhandled_input(event):
	if event is InputEventMouseMotion && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, -1.2, 1.2)

func _process(_delta):
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		return

	weapon_cam.global_transform = camera.global_transform

	if !Input.is_action_just_pressed("fire") || ammo[current_weapon] <= 0:
		return

	fire()

func _physics_process(delta):
	var desired_velocity = get_input() * max_air_speed
	
	if !is_on_floor():
		velocity.y += delta * gravity
	elif desired_velocity.y != 0:
		velocity.y = desired_velocity.y

	velocity.x = lerp(velocity.x, desired_velocity.x, delta * acceleration)
	velocity.z = lerp(velocity.z, desired_velocity.z, delta * acceleration)
	velocity = move_and_slide(velocity, Vector3.UP, true)

	if is_on_floor() && (desired_velocity.x != 0 || desired_velocity.z != 0):
		var t = OS.get_ticks_msec() / SWAY_SPEED
		hand.transform.origin.x = lerp(hand.transform.origin.x, hand_origin.x + cos(t + PI) / SWAY_INTENSITY, delta * HAND_MOTION_LERP_SPEED)
		hand.transform.origin.y = lerp(hand.transform.origin.y, hand_origin.y + cos(t * 2.0) / SWAY_INTENSITY, delta * HAND_MOTION_LERP_SPEED)
		hand.transform.origin.z = lerp(hand.transform.origin.z, hand_origin.z, delta * HAND_MOTION_LERP_SPEED)
	elif hand.transform.origin != hand_origin:
		hand.transform.origin = lerp(hand.transform.origin, hand_origin, delta * HAND_MOTION_LERP_SPEED)

	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		hand.rotation.x = lerp(hand.rotation.x, hand_rotation.x, delta * HAND_MOTION_LERP_SPEED)

func on_pickup(node: Node, type: String, amount: int):
	if node != self:
		return

	var weapon
	match type:
		"AMMO_BLASTER":
			weapon = Weapon.BLASTER

	add_ammo(weapon, amount)

	$HUD.on_pickup(node, type, amount)

func fire():
	var p = Projectile.instance()
	get_parent().add_child(p)
	p.transform = weapon_muzzle.global_transform
	p.rotate_x(rand_range(-weapon_accuracy, weapon_accuracy))
	p.rotate_y(rand_range(-weapon_accuracy, weapon_accuracy))
	p.velocity = -p.transform.basis.z * p.muzzle_velocity
	hand.transform.origin.z += recoil_intensity
	hand.rotate_x(recoil_intensity * 2.0)
	weapon_fire_audio.play()
	remove_ammo(current_weapon, ammo_cost[current_weapon])

func set_ammo(weapon: int, amount: int):
	ammo[weapon] = amount
	if weapon == current_weapon:
		emit_signal("ammo_changed", ammo[weapon])

func add_ammo(weapon: int, amount: int):
	set_ammo(weapon, ammo[weapon] + amount)

func remove_ammo(weapon: int, amount: int):
	set_ammo(weapon, ammo[weapon] - amount)
