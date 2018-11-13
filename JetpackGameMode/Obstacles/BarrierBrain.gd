extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var tentacle_pipe
var collision_top
var collision_bottom
var tentacle_position
var animation

var tentacle_trigger
var is_alive = true

signal player_killed

func _ready():
	initialize_node_variables()
	
	_on_PipeTentacles_Reset()
	
	if not tentacle_trigger.is_connected("body_enter",self,"_on_TentacleTrigger"):
		tentacle_trigger.connect("body_enter",self,"_on_TentacleTrigger")
	
	randomize()

func initialize_node_variables():
	tentacle_pipe = self.get_parent()
	collision_top = tentacle_pipe.get_node("TentaclePath/TentaclePosition/TentacleTopStatic")
	collision_bottom = tentacle_pipe.get_node("TentaclePath/TentaclePosition/TentacleBottomStatic")
	tentacle_position = tentacle_pipe.get_node("TentaclePath/TentaclePosition")
	
	animation = tentacle_pipe.get_node("AnimationPlayer")
	
	tentacle_trigger = self.get_tree().get_root().get_node("JetpackGame/Camera2D/TentacleTrigger")
#	print(tentacle_trigger.get_name())


func _on_TentacleTrigger( body ):
	pass


func _on_PipeTentacles_Reset():
	animation.play("crush")
	tentacle_position.set_unit_offset(0.5)


func _on_kill_player(body, offset_y):
	#print(offset_y)
	#print(tentacle_position.get_global_pos().y)
	var tentacle_top
	var tentacle_bottom
	var dead_player
	var relative_pos = offset_y - tentacle_position.get_global_pos().y
	#print(relative_pos)
	
	if body.get_name() == "TentacleBottomStatic":
		tentacle_bottom = body.get_node("TentacleBottom")
		dead_player = tentacle_bottom.get_node("DeadPlayer")
		offset_y = relative_pos - tentacle_bottom.get_pos().y
	elif body.get_name() == "TentacleTopStatic":
		tentacle_top = body.get_node("TentacleTop")
		dead_player = tentacle_top.get_node("DeadPlayer")
		offset_y = relative_pos - tentacle_top.get_pos().y
	var target_pos = Vector2(dead_player.get_pos().x, offset_y)
	#print(target_pos)
	dead_player.set_pos(target_pos)
	dead_player.show()
	
	animation.play("kill_player")
	yield(animation, "finished")
	tentacle_pipe._on_player_killed()

func _on_PipeTentacles_Die():
	#print("Signal 'Die' Received")
	if is_alive:
		is_alive = false
		tentacle_pipe.scored()
		animation.play_backwards("crush_backwards")
		yield(animation, "finished")
		animation.play("die")

func go_to_crush():
	animation.play("crush")


func _on_VisibilityNotifier2D_exit_screen():
	#print("Kill")
	tentacle_pipe.queue_free()
