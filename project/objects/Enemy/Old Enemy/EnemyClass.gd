class_name OldEnemy
extends Node2D

@export var enemy_health: int = 10;
@export var enemy_max_health: int = 5
@export var damage_enemy: int  = 5
@export var take_damage:bool = false
@export var death_object_scene: PackedScene;
@onready var enemy_bar: ProgressBar = $EnemyBar



func _process(delta):
	
	enemy_bar.max_value = enemy_max_health
	enemy_bar.value = enemy_health

func damage(amount:int) -> void:
	enemy_health -= amount;
	take_damage= true	
	#print("enemy take damage ", amount)
	modulate = Color.RED;
	var tween = create_tween();
	tween.set_ease(Tween.EASE_IN);
	tween.set_trans(Tween.TRANS_QUINT);
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	if enemy_health <= 0:
		die()
	pass

func die()-> void:
	if death_object_scene:
		var death_animation = death_object_scene.instantiate();
		death_animation.position = position;
		get_parent().add_child(death_animation);
		
	GameManager.monster_count += 1
	queue_free()
	pass

