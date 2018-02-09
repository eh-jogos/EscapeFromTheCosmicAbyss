extends Node2D

# class member variables go here, for example:
var countdown
var countdown_label
var game

func _ready():
	countdown = self.get_node("CountdownTimer")
	countdown_label = self.get_node("CountdownLabel")
	
	game = self.get_parent().get_parent()
	pass

func play():
	self.show()
	set_process(true)
	countdown.start()

func _process(delta):
	var time_left = int(countdown.get_time_left())
	if time_left > 0:
		countdown_label.set_text(str(time_left))
	else:
		countdown_label.set_text("START!")

func _on_timeout():
	game.set_game_state(false)
	self.get_tree().set_pause(false)
	self.hide()
	self.set_process(false)
	pass # replace with function body
