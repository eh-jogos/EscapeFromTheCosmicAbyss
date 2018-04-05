extends Node

var animator
var darkwave
var deadplayer 
var deadplayer_outline
var tentacle_position

func _ready():
	darkwave = self.get_parent()
	animator = darkwave.get_node("AnimationPlayer")
	deadplayer = darkwave.get_node("TentaclePath/TentaclePosition/TentacleBottomStatic/TentacleBottom/DeadPlayer")
	deadplayer_outline = darkwave.get_node("TentaclePath/TentaclePosition/TentacleBottomStatic/TentacleBottom/DeadPlayer/DeadPlayerOutline")
	tentacle_position = darkwave.get_node("TentaclePath/TentaclePosition")
	
	animator.play("inactive")

func _on_kill_player(offset_x, flip):
	deadplayer.set_flip_v(flip)
	deadplayer_outline.set_flip_v(flip)
	
	var relative_pos = offset_x - tentacle_position.get_global_pos().x
	#print("Offset X: %s | tentacle position: %s | Relative Pos: %s | Unit Relative Pos? %s"%[offset_x, tentacle_position.get_global_pos().x, relative_pos, relative_pos/(790*3)])
	
	tentacle_position.set_offset(relative_pos)
	
	animator.play("kill_player")
	yield(animator, "finished")
	darkwave._on_player_killed()
	
	tentacle_position.set_unit_offset(0)
	animator.play("inactive")
