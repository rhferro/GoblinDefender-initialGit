class_name MobSpawnnerAround
extends Node2D

#CREATURE LIST WHO WHO CAN BE CREATED
@export var creatures: Array[PackedScene]
var mob_per_minutes: float = 60.0
var interval_spawmer: float = 60/ mob_per_minutes
var cooldown: float = 0.0
@onready var path_follow_2D: PathFollow2D = %AroundPlayer

func _process(delta):
	
	#IF GAME OVER
	if GameManager.is_game_over: return
	
	#frequencia: monstros por minuto
	cooldown -=  delta
	if cooldown > 0: return
	
	#temporizador
	cooldown = interval_spawmer
	
	#criatura aleatoria
	#-pegar criatura alaetoria
	var index_monster = randi_range(0 , creatures.size() - 1)
	var creature_scene = creatures[index_monster]
	#[OK]
	#-pegar ponto aleatorio
	var point = get_point()
	# #nao colocar dentro de um espaço fisico
	var world_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = point
	#parameters.collision_mask
	var result:Array = world_state.intersect_point(parameters, 1)
	if not result.is_empty(): return
	#-instanciar a cena
	var creature = creature_scene.instantiate()
	#-colocar na posição
	creature.global_position = point
	#- definir o node pai
	get_parent().add_child(creature)
	pass

func get_point() -> Vector2:
	path_follow_2D.progress_ratio = randf();
	return path_follow_2D.global_position
