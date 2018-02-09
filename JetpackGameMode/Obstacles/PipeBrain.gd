extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var tentacle_pipe
var tentacle_top
var tentacle_bottom
var animation

var dead_player
var tentacle_trigger

signal player_killed

func _ready():
	tentacle_pipe = self.get_parent()
	tentacle_top = tentacle_pipe.get_node("TentacleTop")
	tentacle_bottom = tentacle_pipe.get_node("TentacleBottom")
	
	animation = tentacle_pipe.get_node("AnimationPlayer")
	
	tentacle_trigger = self.get_tree().get_root().get_node("JetpackGame/Camera2D/TentacleTrigger")
#	print(tentacle_trigger.get_name())
	
	animation.play("bomb")
	
	if not tentacle_trigger.is_connected("body_enter",self,"_on_TentacleTrigger"):
		tentacle_trigger.connect("body_enter",self,"_on_TentacleTrigger")
	
	randomize()
	pass


func _on_TentacleTrigger( body ):
	if body.is_in_group("pipes") and body == tentacle_pipe:
		animation.play("pipes")
		var new_y = tentacle_pipe.get_pos().y + rand_range(-250,250)
		
		tentacle_pipe.set_pos(Vector2(tentacle_pipe.get_pos().x, new_y))
	pass


func _on_PipeTentacles_Reset():
	animation.play("bomb")
	tentacle_pipe.set_pos(Vector2(tentacle_pipe.get_pos().x, 1080/2))
	pass # replace with function body

func _on_player_pass( body ):
	if body.is_in_group("player"):
		tentacle_pipe.emit_signal("scored")
	pass # replace with function body

func _on_kill_player(offset_y):
	if offset_y > 0:
		dead_player = tentacle_bottom.get_node("DeadPlayer")
		if offset_y < 150:
			offset_y = 150 - tentacle_bottom.get_pos().y
		else:
			offset_y = offset_y - tentacle_bottom.get_pos().y
	else:
		dead_player = tentacle_top.get_node("DeadPlayer")
		if offset_y > -150:
			offset_y = -150 - tentacle_top.get_pos().y
		else:
			offset_y = offset_y - tentacle_top.get_pos().y
	var target_pos = Vector2(dead_player.get_pos().x, offset_y)
#	print(target_pos)
	dead_player.set_pos(target_pos)
	dead_player.show()
	
	animation.play("kill_player")
	yield(animation, "finished")
	emit_signal("player_killed")
	pass # replace with function body


func _on_PipeTentacles_Die():
	animation.play("die")
	pass # replace with function body
