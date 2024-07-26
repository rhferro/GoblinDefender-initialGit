extends Area2D

@onready var enemy:Bow_enemy
@onready var arrow_damage_area:Area2D = $ArrowDamage

@onready var sprite_arrow: Sprite2D = $Arrow
@onready var sprite_arrow_on_ground: Sprite2D = $ArrowOnTheGround
@onready var sprite_arrow_on_body: Sprite2D = $ArrowOnBody

var arrow_damage: int
var arrow_speed: int = 10
var last_target_location
var target
var arrow_on_body = false
var on_target_security_time = 1.0
var timer= 0.0

func _ready():
	set_as_top_level(true)
	enemy = get_parent()
	
	arrow_damage = enemy.enemy_damage
	pass

func _process(delta):
	if GameManager.is_game_over: return
	print(enemy.enemy_damage)
	on_target_security_time += delta
	timer += delta
	#print(timer)
	if timer > 8.0:
		queue_free()
	if arrow_on_body:
		sprite_arrow.visible = false
		sprite_arrow_on_body.visible = true
		last_target_location = target.global_position

		position = last_target_location
		return
	if timer > 2.0:

		sprite_arrow.visible = false
		sprite_arrow_on_ground.visible = true
		position = position
		return
	position +=  (Vector2.RIGHT * arrow_speed).rotated(rotation)
	var last_position = global_position


	arrow_shotted()

#
func arrow_shotted()-> void:
	var arrow = arrow_damage_area.get_overlapping_bodies();
	
	for body in arrow:
		if not body.is_in_group("player"):
			#print("não acertou")
			pass
		if body.is_in_group("player"):
			target = body
			print("acertou")
			arrow_on_body = true
			if on_target_security_time > 1.0:
				last_target_location = target.global_position
				target.get_damage(arrow_damage)
				on_target_security_time = 0.0
			
			pass
			


