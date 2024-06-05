extends CharacterBody3D

var path = []
var path_node = 0

var speed = 10

@onready var nav = get_parent()
@onready var player = $"../../Player"

func _ready():
	pass

func _physics_process(delta):
	if path_node >= path.size():
		return
	
	var direction = path[path_node] - global_transform.origin
	if direction.length() < 1:
		path_node += 1
	else:
		set_velocity(direction.normalized() * speed)
		set_up_direction(Vector3.UP)
		move_and_slide()

func move_to(target_pos: Vector3):
	path = nav.get_simple_path(global_transform.origin, target_pos)
	path_node = 0

func on_move_timer_timeout():
	move_to(player.global_transform.origin)
