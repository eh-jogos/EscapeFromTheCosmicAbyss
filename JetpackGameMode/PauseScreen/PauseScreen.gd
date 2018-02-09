extends Node2D

# class member variables go here, for example:
var resume_btn
var current_scene
var tutorial_screen

func _ready():
	resume_btn = self.get_node("Resume")
	resume_btn.grab_focus()
	
	current_scene = get_tree().get_root().get_node("JetpackGame")
	tutorial_screen = current_scene.get_node("AboveScreen/TutorialScreen")
#	print(current_scene)
	
	set_process_input(true)
	pass

func _input(event):
	if event.is_action_pressed("pause") and not current_scene.game_over:
		if self.is_visible():
			resume_game()
		else:
			pause_game()
		pass

func pause_game():
	self.show()
	get_tree().set_pause(true)
	resume_btn.grab_focus()

func resume_game():
	self.hide()
	get_tree().set_pause(false)

func _on_resume_pressed():
	resume_game()

func _on_replay_pressed():
	if current_scene != null:
		get_tree().change_scene("res://JetpackGameMode/JetpackGame.tscn")
		resume_game()

func _on_quit_pressed():
	get_tree().quit()

func _on_tutorial_pressed():
	tutorial_screen.play()
	tutorial_screen.is_paused = true 
	pass # replace with function body

