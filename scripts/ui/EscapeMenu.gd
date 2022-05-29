extends Node

onready var overlay = $Overlay
onready var opt_quit = $Overlay/Items/Quit

func _ready():
	opt_quit.connect("pressed", self, "on_quit")

func _unhandled_input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			overlay.visible = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			overlay.visible = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func on_quit():
	get_tree().quit()
