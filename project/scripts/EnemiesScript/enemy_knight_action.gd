extends Node2D

#iherit enemy class
var enemy: Enemy;
var normal_enemy:bool = false
var boss_enemy:bool = true
@onready var player: Player
var animation_enemy: AnimationPlayer;
var enemySprite: Sprite2D;
var take_damage:bool;
var back_timer:float = 0.0;
@onready var enemy_attack_area: Area2D;
var turn_direction = "right";
var enemy_damage:int = 10
#var enemy_input_vector:Vector2

var dot_product: float
@onready var TIMER: Timer = $Timer2

#ENEMY ATTACK
var ENEMY_ATTACK_COOLDOWN:float = 2.5
const MAX_ENEMY_ATTACK_COOLDOW:float = 2.5
var is_enemy_attacking:bool = false


func _ready():
	enemy = get_parent();
	enemy.enemy_max_health = 30
	enemy.enemy_health = 30
	enemySprite= enemy.get_node("Sprite2D");
	animation_enemy = enemy.get_node("AnimationPlayer")
	enemy_attack_area = enemy.get_node("EnemyAttackArea")
	enemy.damage_enemy = enemy_damage 
	
	enemy.is_enemy_boss = normal_enemy
	
	enemySprite.flip_h= true;


func _physics_process(delta:float) -> void:

	take_damage= enemy.take_damage
	
	if is_enemy_attacking== false:
		animation_enemy.play("enemy-run")
	
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
	
	rotate_enemy()

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
	attack_player()


	TIMER.stop()
