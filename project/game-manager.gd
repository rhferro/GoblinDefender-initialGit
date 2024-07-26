extends Node

signal game_over

var player: Player
var enemy: Enemy
var monster_count: int = 0
var PLAYER_POSITION: Vector2 = Vector2.ZERO
var is_game_over:bool = false
var is_arrow_on_target:bool = false

func arrow():
	is_arrow_on_target = true
	pass

func end_game():
	if is_game_over:return 
	is_game_over = true
	game_over.emit()

func reset():
	player = null
	PLAYER_POSITION = Vector2.ZERO
	monster_count = 0
	is_game_over = false
	for connection in game_over.get_connections():
		game_over.disconnect(connection.callable)
