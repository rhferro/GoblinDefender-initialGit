extends Node2D

var value: int = 0
var is_damage_on_screen:bool = true
@onready var damage_digit: Node2D = $DamageDigit

func _ready():
	%DamageLabel.text = str(value)
	
func _process(delta):
	if is_damage_on_screen ==  false:
		damage_digit.queue_free()

func is_input_label_off()-> void:
	is_damage_on_screen = false
