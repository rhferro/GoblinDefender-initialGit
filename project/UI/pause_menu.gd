extends CanvasLayer
@onready var resume_btn = $MenuHolder/Resume
func _ready():
	visible = false

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		visible = true
		get_tree().paused = true
		resume_btn.grab_focus()

func _on_resume_pressed():
	get_tree().paused = false
	visible= false



func _on_quit_game_pressed():
	get_tree().quit()
