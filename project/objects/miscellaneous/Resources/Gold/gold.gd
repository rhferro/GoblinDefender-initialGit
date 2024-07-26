extends AnimatedSprite2D

#@export var meat_heal: float = 0.1
@onready var meat_area: Area2D

func _ready():
	meat_area= %GoldArea
	meat_area.body_entered.connect(on_body_entered_on_gold)
	
	
func on_body_entered_on_gold(body:Node2D)-> void:
	
	if body.is_in_group("player"):
		var player:Player = body;
		
		player.gold_incresse()
		queue_free()
