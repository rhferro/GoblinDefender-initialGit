extends Area2D

@onready var control_area: Sprite2D = $ControlArea
@onready var on_screen:Sprite2D = $ControlArea/OnScreen

@onready var max_distance = $CollisionShape2D.shape.radius

var touched = false

func _input(event):
	if event is InputEventScreenTouch:
		var distance = event.position.distance_to(control_area.global_position)
		if not touched:
			if distance < max_distance:
				touched = true
		else:
			on_screen.position = Vector2(0,0)
			touched = false

func _process(delta):
	if touched:
		control_area.global_position= get_global_mouse_position()
