extends Node2D

# class member variables go here, for example:
var game
var animator
var level_num
var level_title

func _ready():
	set_process_input(false)
	game = self.get_parent().get_parent()
	animator = self.get_node("AnimationPlayer")
	level_num = self.get_node("LevelNum")
	level_title = self.get_node("LevelTitle")
	
	animator.assigned_animation = "base"
	animator.seek(0,true)
	


func play(num, title):
	self.show()
	#SoundManager.stop_bgm()
	game.set_game_state("Start")
	var stage_text = "%02d"%[num]
	level_num.set_text(stage_text)
	level_title.set_text(title)
	
	animator.play("fade_in")
	yield(animator, "animation_finished")
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("boost"):
		self.set_process_input(false)
		if game.is_tutorial:
			game.set_game_state("Tutorial")
		else:
			game.set_game_state("Playing")
		
		animator.play_backwards("fade_in")
		yield(animator, "animation_finished")
		
		if game.game_mode == "speedrun":
			game.runtime_label.get_node("Timer").start()
		
		self.hide()
		self.get_tree().set_pause(false)
		game.player_reset_y()
		#SoundManager.reset_track()
		SoundManager.bgm_set_loop(true)
		if not SoundManager.bgm_stream.is_playing():
			SoundManager.play_bgm("2")

