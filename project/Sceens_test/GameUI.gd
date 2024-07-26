extends CanvasLayer

@onready var level: Label = %Level
@onready var hp_bar: ProgressBar = %UIHPBar
@onready var hp_number: Label = %UIHPValue
@onready var mp_bar: ProgressBar = %UIMPBar
@onready var mp_number: Label = %UIMPValue
@onready var gold_label: Label = %GoldLabel

var last_hp_bar: int = 0
var last_max_hp_bar: int = 0
var last_mp_bar: int = 0
var last_max_mp_bar: int = 0
var last_player_level: int = 0
var last_gold_value: int = 0

func _process(delta):
	if GameManager.player and is_instance_valid(GameManager.player):
		# LEVEL
		last_player_level = GameManager.player.player_level
		level.text = str(last_player_level)
	
		last_hp_bar = GameManager.player.health
		last_max_hp_bar = GameManager.player.max_health
		# HP BAR
		hp_bar.value = last_hp_bar
		hp_bar.max_value = last_max_hp_bar
		hp_number.text = "%3d / %3d" % [last_hp_bar, last_max_hp_bar]
		
		last_mp_bar = GameManager.player.magic_power
		last_max_mp_bar = GameManager.player.max_magic_power
		# MP BAR
		mp_bar.value = last_mp_bar
		mp_bar.max_value = last_max_mp_bar
		mp_number.text = "%3d / %3d" % [last_mp_bar, last_max_mp_bar]
		#"move_left", "move_right", "move_up", "move_down"
		#GOLD
		last_gold_value = GameManager.player.gold
		gold_label.text = str(GameManager.player.gold)
	else:
		# Mostrar o último nível conhecido
		level.text = str(last_player_level)

		# Zerar os valores de vida e mana
		hp_bar.value = 0
		hp_bar.max_value = last_max_hp_bar
		hp_number.text = "%3d / %3d" % [0, last_max_hp_bar]
		
		# MP BAR
		mp_bar.value = 0
		mp_bar.max_value = last_max_mp_bar
		mp_number.text = "%3d / %3d" % [0, last_max_mp_bar]
		
		#GOLD
		gold_label.text = str(last_gold_value)
