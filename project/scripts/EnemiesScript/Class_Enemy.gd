class_name Enemy
extends CharacterBody2D

var is_enemy_boss:bool = false
var is_enemy_bow:bool = false

var last_target_location 
@onready var target:Node2D =  get_node("/root/Game/Player/Target")
@export var enemy_health: int = 10;
@export var enemy_max_health: int = 10
@export var damage_enemy: int = 5
var take_damage:bool = false
@export var death_object_scene: PackedScene;
@onready var enemy_bar: ProgressBar = $EnemyBar

#DROP AREA
@export_category("Drop")
@export var drop: Array[PackedScene]

var speed = 1000
var acc = 7
var test_velocity: Vector2
@onready var nav_agent: NavigationAgent2D = $Actions/NavigationAgent2D
var direction = Vector2.ZERO
var velocity_initial: Vector2

@onready var enemy_area_distance: Area2D = $EnemyAttackArea
@onready var enemy_collision: Area2D = %SpecialBowArea
var arrow_damage_value:int = 5

func _ready():
	if nav_agent.target_position == null:
		nav_agent = %target
	if enemy_collision == null:
		print("SpecialBowArea não encontrado!")
func drop_enemy():
	
	if is_enemy_boss:
		#GREAT AWARD
		pass
	else:
		if drop:
			#-pegar criatura alaetoria
			var index_drop = randi_range(0 , drop.size() - 1)
			var enemy_drop_scene = drop[index_drop]
			var drop_animation = enemy_drop_scene.instantiate()
			drop_animation.position = position
			get_parent().add_child(drop_animation)
			
		pass

#MOVEMENT
func _physics_process(delta):
	if GameManager.is_game_over: return
	const area_distance = Vector2(600, 40)
	const safe_area_distance = area_distance/2
	var enemy_distance_area = floor(abs(self.global_position - GameManager.PLAYER_POSITION))
	
	if is_enemy_bow:
		var body_bow_area = enemy_area_distance.get_overlapping_bodies()
		var body_bow_limit = enemy_collision.get_overlapping_bodies()

		for body_area in body_bow_area:
			if body_area.is_in_group("player"):
				#BOW RESCUE
				if enemy_distance_area <= safe_area_distance:
					direction = nav_agent.get_next_path_position() - global_position
					direction = (self.global_position - GameManager.PLAYER_POSITION).normalized()
					test_velocity = velocity_initial.lerp(direction * speed, acc * delta)
					velocity = test_velocity
					
					if enemy_distance_area >= safe_area_distance and enemy_distance_area <= area_distance:
						velocity = test_velocity
						velocity = Vector2.ZERO
						
					
					for body_limit in body_bow_limit:
						if body_limit.is_in_group("obstacle"):
							velocity = Vector2.ZERO
							move_and_slide()
							return
					
					move_and_slide()
					
					return
				else:
					#BOW JUST STOP
					velocity = Vector2.ZERO

				return
			if not body_area.is_in_group("player"):

				velocity = test_velocity
	
	if not nav_agent.is_navigation_finished():
		direction = nav_agent.get_next_path_position() - global_position
		direction = direction.normalized()
		
		test_velocity = velocity_initial.lerp(direction * speed, acc * delta)
		velocity = test_velocity
	else:
		test_velocity = Vector2.ZERO

	
	move_and_slide()

func _process(delta):
	
	enemy_bar.max_value = enemy_max_health
	enemy_bar.value = enemy_health

func damage(amount:int) -> void:
	enemy_health -= amount;
	take_damage= true
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
		
	#GameManager.monster_count += 1
	queue_free()
	drop_enemy()
	pass


func _on_timer_timeout():
	if target == null:
		nav_agent.target_position = Vector2.ZERO
		return
	nav_agent.target_position = target.global_position
	last_target_location = target.global_position
	pass # Replace with function body.
