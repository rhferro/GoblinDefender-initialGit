class_name Enemy_Structure
extends Node2D


var structure_health: int = 200
var max_structure_health: int = 200
@export var creatures: Array[PackedScene]
var interval_spawmer: float = 0.25
var interval_cooldown: float = 20
var mob_spawmed:int = 0
var is_build_on:bool = true
const max_mob_spawmed: int = 3
var cooldown: float = 0.0
@export var destroyed_structure_packed_sceen: PackedScene
@onready var damage_structure_1:Node2D = $RedCastleDamage1
@onready var damage_structure_2:Node2D = $RedCastleDamage2
@onready var structure_bar: ProgressBar = $StructureBar
@onready var path_follow_2D: PathFollow2D = %PathFollow2D
@onready var structure_sprite2d: Sprite2D = $Sprite2D
@onready var structure_animation: AnimationPlayer = $AnimationPlayer

var current_damage_scene: Node2D = null

func _process(delta):

	#IF GAME OVER
	if GameManager.is_game_over: return
	
	structure_bar.max_value = max_structure_health
	structure_bar.value = structure_health
	
	#frequencia: monstros por minuto
	cooldown -=  delta
	if cooldown > 0: return
	
	#temporizador
	cooldown = interval_spawmer
	if is_build_on:
		if mob_spawmed == max_mob_spawmed:
			
			cooldown = interval_cooldown
			mob_spawmed = 0
		if mob_spawmed <3 and cooldown != 0.0:
			
			#criatura aleatoria
			#-pegar criatura alaetoria
			var index_monster = randi_range(0 , creatures.size() - 1)
			var creature_scene = creatures[index_monster]
			#[OK]
			#-pegar ponto aleatorio
			#var point = get_point()
			#-instanciar a cena
			var creature = creature_scene.instantiate()
			#-colocar na posição
			creature.global_position = get_point()
			#- definir o node pai
			get_parent().add_child(creature)
			mob_spawmed += 1
	pass



func get_point() -> Vector2:
	path_follow_2D.progress_ratio = randf();
	return path_follow_2D.global_position

func damage_to_structure(amount:int) -> void:
	structure_health -= amount;
	structure_animation.play("get_damage")
	print("Castle take damage ", amount)
	#modulate = Color.RED;
	#var tween = create_tween();
	#tween.set_ease(Tween.EASE_IN);
	#tween.set_trans(Tween.TRANS_QUINT);
	#tween.tween_property(self, "modulate", Color.WHITE, 0.3)
	
	if structure_health < max_structure_health:
		structure_sprite2d.visible = false
		
		if structure_health > floor(max_structure_health / 2):
			damage_structure_1.visible = true
		
		
		if structure_health < floor(max_structure_health / 2):
			damage_structure_1.visible = false
			damage_structure_2.visible = true
			
		
		if structure_health <= 0:
			damage_structure_2.visible = false
			structure_bar.visible = false
			is_build_on = false
			destroyed()

	pass

func destroyed()-> void:
	if destroyed_structure_packed_sceen:
		var tower_destroied = destroyed_structure_packed_sceen.instantiate();
		tower_destroied.position = position;
		get_parent().add_child(tower_destroied);


