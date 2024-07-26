class_name GameOverUI
extends CanvasLayer

@onready var monster_count_label: Label = %ValueMonstersCount
@export var restart_delay: float = 5.0


var restart_cooldown: float


func _ready():
	monster_count_label.text = str(GameManager.monster_count)
	restart_cooldown = restart_delay

func _process(delta):
	restart_cooldown -= delta
	if restart_cooldown <= 0:
		restart_game()

func restart_game():
	GameManager.reset()
	get_tree().reload_current_scene()
	print("restart")
