extends Node

@onready var overlay = $Overlay
@onready var opt_continue = $Overlay/Items/Continue
@onready var opt_quit = $Overlay/Items/Quit

func _ready():
	opt_continue.connect("pressed", Callable(self, "on_continue"))
	opt_quit.connect("pressed", Callable(self, "on_quit"))

func _unhandled_input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			get_tree().paused = true
			overlay.visible = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			get_tree().paused = false
			overlay.visible = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func on_continue():
	get_tree().paused = false
	overlay.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func on_quit():
	get_tree().paused = false
	get_tree().quit()
