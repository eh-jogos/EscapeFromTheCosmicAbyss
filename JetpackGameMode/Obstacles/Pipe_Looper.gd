extends Node2D

export var point_value = 1
var game

# warning-ignore:unused_signal
signal die

func _ready():
	game = self.get_tree().get_root().get_node("JetpackGame")


func _on_player_killed():
	game.game_over()

func scored():
	game._on_scored(point_value)
	Global.achievements_handler.current_mileage += point_value
