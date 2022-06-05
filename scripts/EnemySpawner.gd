extends Node

export (NodePath) var NavigationNode
export (PackedScene) var Enemy

export var cooldown_time = 5
export var max_spawns = 10

onready var timer: Timer = $Timer
onready var nav = get_node(NavigationNode)

var spawns = 0

func _ready():
	timer.wait_time = cooldown_time

func reset():
	timer.stop()
	spawns = 0
	timer.wait_time = cooldown_time
	timer.start()

func on_timer_timeout():
	var e = Enemy.instance()
	e.global_transform = self.global_transform
	nav.add_child(e)
	spawns += 1

	if spawns == max_spawns:
		timer.stop()
