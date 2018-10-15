extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var tentacle_pipe
var collision_top
var collision_bottom
var tentacle_position
var tentacle_top
var tentacle_bottom
var animation

var dead_player
var tentacle_trigger

signal player_killed

func _ready():
	tentacle_pipe = self.get_parent()
	collision_top = tentacle_pipe.get_node("TentaclePath/TentaclePosition/TentacleTopStatic")
	collision_bottom = tentacle_pipe.get_node("TentaclePath/TentaclePosition/TentacleBottomStatic")
	tentacle_position = tentacle_pipe.get_node("TentaclePath/TentaclePosition")
	tentacle_top = tentacle_pipe.get_node("TentaclePath/TentaclePosition/TentacleTopStatic/TentacleTop")
	tentacle_bottom = tentacle_pipe.get_node("TentaclePath/TentaclePosition/TentacleBottomStatic/TentacleBottom")
	
	animation = tentacle_pipe.get_node("AnimationPlayer")
	
	tentacle_trigger = self.get_tree().get_root().get_node("JetpackGame/Camera2D/TentacleTrigger")
#	print(tentacle_trigger.get_name())
	
	animation.play("hidden")
	
	if not tentacle_trigger.is_connected("body_enter",self,"_on_TentacleTrigger"):
		tentacle_trigger.connect("body_enter",self,"_on_TentacleTrigger")
	
	randomize()
	pass


func _on_TentacleTrigger( body ):
	if body.is_in_group("pipes") and (body == collision_top or body == collision_bottom):
		animation.play("spawn")
		tentacle_position.set_unit_offset(rand_range(0.0,1.0))
	pass


func _on_PipeTentacles_Reset():
	animation.play("hidden")
	tentacle_position.set_unit_offset(0.5)
	pass # replace with function body

func _on_player_pass( body ):
	if body.is_in_group("player"):
		tentacle_pipe.emit_signal("scored")
		animation.play("die")
	pass # replace with function body

func _on_kill_player(offset_y):
	#print(offset_y)
	#print(tentacle_position.get_global_pos().y)
	var relative_pos = offset_y - tentacle_position.get_global_pos().y
	#print(relative_pos)
	if relative_pos > 0:
		dead_player = tentacle_bottom.get_node("DeadPlayer")
		offset_y = relative_pos - tentacle_bottom.get_pos().y
	else:
		dead_player = tentacle_top.get_node("DeadPlayer")
		offset_y = relative_pos - tentacle_top.get_pos().y
	var target_pos = Vector2(dead_player.get_pos().x, offset_y)
	#print(target_pos)
	dead_player.set_pos(target_pos)
	dead_player.show()
	
	animation.play("kill_player")
	yield(animation, "finished")
	tentacle_pipe._on_player_killed()
	pass # replace with function body

func _on_PipeTentacles_Die():
	#print("Signal 'Die' Received")
	animation.play("die")
	pass # replace with function body

func go_to_idle():
	animation.play("idle")
