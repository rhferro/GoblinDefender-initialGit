class_name Bow_enemy
extends Node2D

#iherit enemy class
var enemy: Enemy;
var normal_enemy:bool = false
var boss_enemy:bool = true
@onready var player: Player
var animation_enemy: AnimationPlayer;
var enemySprite: Sprite2D;
var enemy_mark: Marker2D
var take_damage:bool;
var back_timer:float = 0.0;
@onready var enemy_attack_area: Area2D;
var turn_direction = "right";
var enemy_damage:int = 15;
#var enemy_input_vector:Vector2

var dot_product: float
@onready var TIMER: Timer = $Timer2

#ENEMY ATTACK
var ENEMY_ATTACK_COOLDOWN:float = 2.5
const MAX_ENEMY_ATTACK_COOLDOW:float = 4.0
var is_enemy_attacking:bool = false

var bow_enemy: bool = false
var bow_cooldown:bool = true
var is_walking:bool = true
var cooddown_animation_idle: float= 0.7
const max_cooddown_animation_idle: float = 0.7

var arrow_preload = preload("res://objects/miscellaneous/Arrow/arrow.tscn")
@export var arrow_sceen: PackedScene
var is_arrow_on_target: bool
var arrow_area_2D: Area2D

func _ready():
	enemy = get_parent();
	enemy.enemy_max_health = 15
	enemy.enemy_health = 15
	enemy.arrow_damage_value = enemy_damage
	enemySprite= enemy.get_node("Sprite2D");
	animation_enemy = enemy.get_node("AnimationPlayer")
	enemy_attack_area = enemy.get_node("EnemyAttackArea")
	enemy_mark = enemy.get_node("Marker2D")
	is_arrow_on_target =  GameManager.is_arrow_on_target
	#TYPE ENEMY
	enemy.is_enemy_boss = normal_enemy
	enemy.is_enemy_bow= true
	
	enemySprite.flip_h= true;


func _physics_process(delta:float) -> void:
	if GameManager.game_over: true
	cooddown_animation_idle += delta
	take_damage= enemy.take_damage
	
	if is_enemy_attacking== false :
		animation_enemy.play("enemy-run")
	if enemy.velocity == Vector2.ZERO and cooddown_animation_idle > max_cooddown_animation_idle:
		is_walking = false
		animation_enemy.play("enemy-idle")
		
	if not enemy.velocity == Vector2.ZERO:
		is_walking = true
		
	
	#DAMAGE
	if take_damage == true:

		back_timer+= delta
		if back_timer < 0.5:
			
			is_enemy_attacking = false
			dot_product= 0.0
			
			animation_enemy.play("enemy-idle")
			enemy.direction *= -1
		
		else:	
			back_timer= 0.0
			enemy.velocity *= 1
			animation_enemy.play("enemy-run")
			enemy.take_damage = false
	
	ENEMY_ATTACK_COOLDOWN += delta;
	if is_enemy_attacking == false and ENEMY_ATTACK_COOLDOWN > MAX_ENEMY_ATTACK_COOLDOW:

		ENEMY_ATTACK_COOLDOWN= 0.0
		is_enemy_attacking = true
		


		detect_player_body();
		TIMER.start();
		
	#NEED ACTIVE
	attack_direction(enemy.direction);
	
	if is_arrow_on_target:
		for i in range(1):
			#print("shot")
			attack_player()
			GameManager.is_arrow_on_target = false
	
	rotate_enemy()

@onready var arrow_position:Vector2	
func bow_shot():
	var player_position = GameManager.PLAYER_POSITION
	enemy_mark.look_at(player_position)
	
	if bow_cooldown:
		bow_cooldown = false
		var arrow_instance = arrow_sceen.instantiate()
		arrow_instance.rotation = enemy_mark.rotation
		arrow_instance.position = global_position
		#get_parent().call_deferred("add_child", arrow_instance)
		add_child(arrow_instance)
	
		
		#for player_body in arrow:
			#print(player_body)
			#if player_body.is_in_group("player"):
				#print("acertou")
				#pass
		
		
		await get_tree().create_timer(4.0).timeout
		bow_cooldown= true

func rotate_enemy()-> void:
	if enemy.direction.x > 0:
		enemySprite.flip_h = false

	elif enemy.direction.x < 0:
		enemySprite.flip_h = true

func detect_player_body()-> void:
	var bodies =  enemy_attack_area.get_overlapping_bodies();
	

	for body in bodies:
		if not body.is_in_group("player"):
			
			pass
		if body.is_in_group("player"):
			player= body
			
			var turn_attack_direction = (player.position - enemy.position).normalized();
			var enemy_attack_side: Vector2;
			
			is_enemy_attacking = true
			cooddown_animation_idle = 0.0
			if turn_direction == "up":

				enemy_attack_side = Vector2.UP
				animation_enemy.play("enemy-attack-up")
				

			if turn_direction == 'down':

				enemy_attack_side = Vector2.DOWN
				animation_enemy.play("enemy-attack-down")
			if turn_direction == "right":
				if enemySprite.flip_h:
					enemy_attack_side = Vector2.LEFT
					animation_enemy.play("enemy-attack-side")
				elif !enemySprite.flip_h:
					enemy_attack_side = Vector2.RIGHT
					animation_enemy.play("enemy-attack-side")
			
			dot_product = turn_attack_direction.dot(enemy_attack_side)
			
			return

func attack_player()-> void:
	arrow_area_2D
	var bodies = arrow_area_2D.get_overlapping_bodies()
	
	if player in bodies:
		player.get_damage(enemy_damage)
		is_enemy_attacking =  false
	if is_enemy_attacking == false:
		dot_product= 0

func attack_direction(enemy_vector) -> void:
	if abs(enemy_vector.x) > abs(enemy_vector.y):
		if enemy_vector.x > 0.0 or enemy_vector.x < 0.0:
			turn_direction = "right"
	else:
		if enemy_vector.y < 0.0:
			turn_direction = "up"
		elif enemy_vector.y > 0.0:
			turn_direction = "down"
	pass

func _on_timer_timeout():

	is_enemy_attacking= false
	


	TIMER.stop()
