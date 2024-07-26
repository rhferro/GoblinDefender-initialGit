class_name Player
extends CharacterBody2D

var original_vector:Vector2
var int_vector: Vector2 = Vector2.ZERO

@export_category("Attack")
@export var SWORD_DAMAGE: int = 10

@export_category("Health")
@export var health:int = 100
@export var max_health: int = 100
@onready var health_bar: ProgressBar = %HealthBar
var magic_power: int = 50
var max_magic_power: int = 50

var gold: int = 0
@export_category("Speed")
@export var SPEED:float = 2;

@export_category("Death Sceen")
@export var player_death_object_scene: PackedScene;

@export_category("magic")
@export var magic_damage_amount: int = 5;
@export var cooldown_magic: float = 0.0;
@export var magic_cooldown_wait:float = 15
@export var magic_packed_sceen: PackedScene

#TIMER ATTACK
const time_attack: float = 0.6
var COOL_DOWN_ATTACK: float = 0.075
var animation_attack_is_running: bool = false
var wait_time = 0.0
var MAX_TIME_ATTACK:float = 1.5

#DASH
var input_vector: Vector2 = Vector2(0,0)
var COOL_DOWN_DASH: float = 0.0
var DASH_VALUE:float = 2
const DASH_COOLDOWN_TIME = 5.0 
var is_in_dash:bool = false
var is_running: bool = false;
var collision_mask_2_desable = false
var collision_cooldown:float = 0.0

#GET INPUT VECTOR INITIAL
const idle = Vector2(0,0);
@onready var animation_player: AnimationPlayer = $AnimationPlayer;
@onready var spritePlayer:Sprite2D = $Sprite2D
@onready var TIMER: Timer = $Timer;
#ATTACK AREA
@onready var ATTACK_AREA: Area2D = $AttackArea

#PLAYER STATUS
var player_level: int = 3
var vitality: int  = 1
var strength: int = 1
var dexterity: int  = 1
var speed: int = 1
var inteligence: int = 1

#DIRECTION
var turn_direction = "right"

func _ready():
	GameManager.player = self
	spritePlayer.flip_h = false;

func _process(delta):
	original_vector = self.global_position
	int_vector = Vector2(floor(original_vector.x), floor(original_vector.y))
	GameManager.PLAYER_POSITION = int_vector
	#print(GameManager.PLAYER_POSITION)
	wait_time += delta
	#GameManager.PLAYER_POSITION = position
	
	
	
	read_input()	
	if Input.is_action_pressed("attack") and wait_time > MAX_TIME_ATTACK:
		animation_attack_is_running = true;
		wait_time = 0.0
		
	if animation_attack_is_running == true and wait_time > time_attack:
		animation_attack_is_running = false;
	
	if !animation_attack_is_running:
		attack_direction()
	#Animação
	all_animation_player()
	
	#update health
	health_bar.value = health
	health_bar.max_value = max_health
	
	#update magic
	update_magic(delta)
	
	#DESABLE ENEMY MASK FOR A WHILE
	collision_cooldown -= delta
	
	if collision_cooldown <= 0:
		set_collision_mask_value ( 2, true )
		collision_cooldown = false
		
		
			


func _physics_process(delta: float) -> void:

	#CALCULATE VELOCITY 
	var target_velocity = input_vector * SPEED * 200

	if animation_attack_is_running:
		target_velocity *= 0.25

	velocity = lerp(velocity, target_velocity,0.05);

	
	COOL_DOWN_DASH += delta
	if Input.is_action_pressed("dash") and COOL_DOWN_DASH > DASH_COOLDOWN_TIME:
		COOL_DOWN_DASH=0.0
		SPEED = 5
		
		is_in_dash= true
		TIMER.start()

	move_and_slide();
	#handleCollision()

func read_input() -> void:
	#input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down");
	input_vector.x = Input.get_axis("move_left", "move_right")
	input_vector.y = Input.get_axis("move_up", "move_down")
	#apagar deadzone dos controles
	var deadzone = 0.15;
	if abs(input_vector.x) < deadzone:
		input_vector.x = 0.0
	if abs(input_vector.y) < deadzone:
		input_vector.y = 0.0

func deal_damage_to_enemy()-> void:
	#BODY DETECT
	var bodies = ATTACK_AREA.get_overlapping_bodies();
	
	print(bodies)
	for body in bodies:
		if body.is_in_group("enemies"):
			##### MUDEI AQUI
			var enemy: Enemy = body

			var turn_attack_direction = (enemy.position - position).normalized()
			var my_attack_side: Vector2

			if turn_direction == "up":

				my_attack_side = Vector2.UP
			if turn_direction == 'down':

				my_attack_side = Vector2.DOWN
			if turn_direction == "right":
				if spritePlayer.flip_h:
					my_attack_side = Vector2.LEFT
				elif !spritePlayer.flip_h:
					my_attack_side = Vector2.RIGHT

			var dot_product = turn_attack_direction.dot(my_attack_side)
			
			if dot_product > 0.3:
				enemy.damage(SWORD_DAMAGE)

		elif body.is_in_group("enemyStructure"):
			var enemy_structure: Enemy_Structure = body
			

			var turn_attack_direction = (enemy_structure.position - position).normalized()
			var my_attack_side: Vector2

			if turn_direction == "up":

				my_attack_side = Vector2.UP
			if turn_direction == 'down':

				my_attack_side = Vector2.DOWN
			if turn_direction == "right":
				if spritePlayer.flip_h:
					my_attack_side = Vector2.LEFT
				elif !spritePlayer.flip_h:
					my_attack_side = Vector2.RIGHT

			var dot_product = turn_attack_direction.dot(my_attack_side)
			
			if dot_product > 0.3:
				enemy_structure.damage_to_structure(SWORD_DAMAGE)		

	pass

func attack_side() -> void:
	
	if turn_direction == "up":	
		animation_player.play("attack_up")
	elif turn_direction == "down":
		animation_player.play("attack_down")
	else:
		animation_player.play("attack_side")
	pass

func attack_direction() -> void:

	if input_vector.y < 0.0:
		turn_direction = "up"

	elif input_vector.y > 0.0:
		turn_direction = "down"

	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		turn_direction = 'right'

func rotate_sprite() -> void:
	if input_vector.x > 0:
		spritePlayer.flip_h = false

	elif input_vector.x < 0:
		spritePlayer.flip_h = true

func all_animation_player() -> void:
	if !animation_attack_is_running:
		if input_vector != idle:
			is_running = true;
			animation_player.play("run");

		if input_vector == idle:
			is_running = false;
			animation_player.play("idle");

		if is_in_dash:
			animation_player.play("dash")
	if animation_attack_is_running:
		attack_side()
	if !animation_attack_is_running:
		rotate_sprite()

func get_damage(damage_enemy: int)-> void:
	collision_mask_2_desable = true
	set_collision_mask_value ( 2, false )
	collision_cooldown = 0.5
	health -= damage_enemy;
	#take_damage= true	

	#print("Player taked damage: ", damage_enemy, "\n player has ", health, " of life.");

	modulate = Color.RED;
	var tween = create_tween();
	tween.set_ease(Tween.EASE_IN);
	tween.set_trans(Tween.TRANS_QUINT);
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)

	if health <= 0:
		die()
	pass

func die()-> void:
	GameManager.end_game()
	
	if player_death_object_scene:
		var death_animation = player_death_object_scene.instantiate();
		death_animation.position = position;
		get_parent().add_child(death_animation);

	queue_free()
	pass

func gold_incresse()-> void:
	var gold_value = randi_range(5 , 10)
	print("GOLD: ",gold_value)
	gold += gold_value
	pass

func meat_restore_life()-> void:
	
	var percent = floori(max_health * 0.1)
	health += percent;
	if health > max_health:
		health = max_health
	
	#print("vida atual: ",health, "vida máxima: ", max_health)

func update_magic(delta:float) -> void:
	cooldown_magic += delta
	
	if cooldown_magic > magic_cooldown_wait:

		if magic_packed_sceen:

			var magic_animation = magic_packed_sceen.instantiate()
			magic_animation.damage_magic = magic_damage_amount
			add_child(magic_animation)
			cooldown_magic = 0.0

			
	else: return

func _on_timer_timeout():
	SPEED = 2
	is_in_dash= false

	TIMER.stop()



