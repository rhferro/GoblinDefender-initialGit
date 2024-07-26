extends Node2D

@export var damage_magic: int  = 10
@onready var magic_damage_area:Area2D = $Magic_Damage_Area

func deal_magic_damage() -> void:
	#Area 2D and CollisionShape 2D ok
	#pegar corpos (get_overlaping_bodies)
	var bodies = magic_damage_area.get_overlapping_bodies()
	
	#verificar grupos is in bodies
	for body in bodies:
		if body.is_in_group("enemies"):
			var enemy:Enemy = body
			#chamar enemy damage
			enemy.damage(damage_magic)
	pass
