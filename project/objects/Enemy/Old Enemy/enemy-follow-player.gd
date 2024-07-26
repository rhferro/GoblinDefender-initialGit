extends Node

@export var ENEMY_SPEED: float = 2;


#iherit enemy class
var enemy: OldEnemy;
@onready var player:Player
var animation_enemy: AnimationPlayer;
var enemySprite: Sprite2D;
var take_damage:bool;
var back_timer:float = 0.0;
@onready var enemy_attack_area: Area2D;
var turn_direction = "right";
var enemy_damage:int;
var enemy_input_vector:Vector2

var dot_product: float
@onready var TIMER: Timer = $Timer

#ENEMY ATTACK
var ENEMY_ATTACK_COOLDOWN:float = 1.6
const MAX_ENEMY_ATTACK_COOLDOW:float = 1.6
var is_enemy_attacking:bool = false


func _ready():
	enemy = get_parent();
	enemy.enemy_max_health = 15
	enemy.enemy_health = 15
	enemySprite= enemy.get_node("Sprite2D");
	animation_enemy = enemy.get_node("AnimationPlayer")
	enemy_attack_area = enemy.get_node("EnemyAttackArea")
	enemy_damage = enemy.damage_enemy
	
	enemySprite.flip_h= true;


func _physics_process(delta:float) -> void:
	
	#IF GAME OVER
	if GameManager.is_game_over: return
	
	take_damage= enemy.take_damage
	
	if not is_instance_valid(GameManager.player): 
		return;
	
	#ENEMY DIRECTION
	var get_player_position = GameManager.PLAYER_POSITION;
	var difference = get_player_position - enemy.position;
	enemy_input_vector = difference.normalized()

	#MOVEMENT
	enemy.velocity = enemy_input_vector * ENEMY_SPEED * 50.0

	
	if is_enemy_attacking== false:
		animation_enemy.play("enemy-run")
	
	#DAMAGE
	if take_damage == true:

		back_timer+= delta
		if back_timer < 0.5:
			is_enemy_attacking = false
			dot_product= 0.0
			animation_enemy.play("enemy-idle")
			enemy.velocity *= -1
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


	attack_direction(enemy_input_vector);

	enemy.move_and_slide();

	#ROTATE
	rotate_enemy()

func rotate_enemy()-> void:
	if enemy_input_vector.x > 0:
		enemySprite.flip_h = false

	elif enemy_input_vector.x < 0:
		enemySprite.flip_h = true

# ################ ate aqui ok

func detect_player_body()-> void:
	var bodies =  enemy_attack_area.get_overlapping_bodies();

	for body in bodies:
		if body.is_in_group("player"):
			player= body;
			print(player)
			var turn_attack_direction = (player.position - enemy.position).normalized();
			var enemy_attack_side: Vector2;
			
			is_enemy_attacking = true
				
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
	var bodies = enemy_attack_area.get_overlapping_bodies()
	
	if player in bodies and dot_product > 0.3:
		player.get_damage(enemy_damage)

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
	attack_player()

	TIMER.stop()



func _on_follow_timer_timeout():
	pass # Replace with function body.
