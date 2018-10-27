extends Node2D

var game

signal die

func _ready():
	game = self.get_tree().get_root().get_node("JetpackGame")


func _on_player_killed():
	game.game_over()

func scored():
	game._on_scored()