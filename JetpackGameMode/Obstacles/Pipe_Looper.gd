extends Node2D

export var point_value = 1
var game

signal die

func _ready():
	game = self.get_tree().get_root().get_node("JetpackGame")


func _on_player_killed():
	game.game_over()

func scored():
	game._on_scored(point_value)


func stop_all_sfx():
	var sfx_player = get_node("SamplePlayer")
	sfx_player.stop_all()