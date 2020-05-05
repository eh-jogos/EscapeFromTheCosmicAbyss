extends Node2D

export(String, FILE) var main_menu_path
export(String, FILE) var options_path
export(String, FILE) var level_select_path

# class member variables go here, for example:
var resume_btn
var options_btn
var level_select_btn
var animator

var last_focus

var game

func _ready():
	set_process_input(true)
	
	animator = self.get_node("AnimationPlayer")
	
	resume_btn = self.get_node("ButtonsBlock/Resume")
#	resume_btn.grab_focus()
	
	options_btn = self.get_node("ButtonsBlock/Options")
	level_select_btn = self.get_node("ButtonsBlock/LevelSelect")
	
	game = self.get_parent().get_parent()
	
	if not options_btn.is_connected("focus_entered",self,"_on_focus_enter"):
		options_btn.connect("focus_entered",self,"_on_focus_enter")
	
	if not level_select_btn.is_connected("focus_entered",self,"_on_focus_enter"):
		level_select_btn.connect("focus_entered",self,"_on_focus_enter")
	
	pass

func _input(event):
	if event.is_action_pressed("pause") and (game.get_game_state() == 0 or game.get_game_state() == 2):
		if self.is_visible():
			resume_game()
		else:
			pause_game()

func pause_game():
	game.set_game_state("Pause")
	game.hud_animator.play("fade_out")
	self.show()
	get_tree().set_pause(true)
	
	animator.play_backwards("fade out")
	yield(animator, "animation_finished")
	
	resume_btn.grab_focus()
	
	#SoundManager.pause_bgm()
	SoundManager.fade_out_start()

func resume_game():
	if game.is_tutorial:
		game.set_game_state("Tutorial")
	else:
		game.set_game_state("Playing")
	
	animator.play("fade out")
	yield(animator, "animation_finished")
	
	self.hide()
	get_tree().set_pause(false)
	game.player_reset_y()
	#SoundManager.pause_bgm()
	SoundManager.fade_in_start()


func _on_resume_pressed():
	resume_game()

func _on_replay_pressed():
	if game != null:
		get_tree().change_scene("res://JetpackGameMode/JetpackGame.tscn")
		resume_game()

func _on_quit_pressed():
	get_tree().quit()


func _on_options_pressed():
	var path = options_path
	last_focus = options_btn
	
	animator.play("fade out")
	yield(animator, "animation_finished")
	
	self.hide()
	
	ScreenManager.load_above(path, last_focus, self)
	SoundManager.pause_bgm()

func _on_focus_enter():
	#print("FOCUS GRABBED")
	if not visible:
		self.show()
		animator.play_backwards("fade out")
		yield(animator, "animation_finished")
		
		SoundManager.pause_bgm()


func _on_LevelSelect_pressed():
	var path = level_select_path
	last_focus = level_select_btn.get_path()
	
	animator.play("fade out")
	yield(animator, "animation_finished")
	
	self.hide()
	
	ScreenManager.load_above(path, last_focus, self)


func _on_QuitMainMenu_pressed():
	SoundManager.stop_bgm()
	ScreenManager.load_screen(main_menu_path)

