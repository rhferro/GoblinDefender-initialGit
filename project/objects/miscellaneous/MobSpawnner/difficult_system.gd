extends Node

@onready var mob_spawnner: MobSpawnnerAround
@export var initial_spawn_rate: float = 30
@export var spawn_rate_per_minutes: float = 60
@export var wave_duration: float = 20
@export var break_intensity: float = 0.33

var time: float = 0.0

func _ready() -> void:
	# Certifique-se de que mob_spawnner está atribuído a um nó válido
	mob_spawnner = get_parent()
	if mob_spawnner == null:
		print("Erro: mob_spawnner não está atribuído corretamente!")
	else:
		print("mob_spawnner inicializado com sucesso.")

func _process(delta: float) -> void:
	#IF GAME OVER
	if GameManager.is_game_over: return
	
	time += delta 
	
	#linear difficult
	var spawn_rate = initial_spawn_rate + spawn_rate_per_minutes * (time/60)

	#senoidal difficult	
	var sin_wave = sin((time * TAU) / wave_duration)
	
	var wave_factor = remap(sin_wave, -1.0, 1.0, break_intensity, 1)
	
	spawn_rate *= wave_factor
	mob_spawnner.mob_per_minutes = spawn_rate
