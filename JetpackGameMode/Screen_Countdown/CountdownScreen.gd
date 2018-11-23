extends Node2D

# class member variables go here, for example:
var game
var animator
var level_num
var level_title

func _ready():
	game = self.get_parent().get_parent()
	animator = self.get_node("AnimationPlayer")
	level_num = self.get_node("LevelNum")
	level_title = self.get_node("LevelTitle")
	pass

func play(num, title):
	self.show()
	#SoundManager.stop_bgm()
	game.set_game_state("Start")
	game.initialize_game_stats()
	level_num.set_text(num)
	level_title.set_text(title)
	
	animator.play("fade_in")
	yield(animator,"finished")
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("boost"):
		game.set_game_state("Playing")
		self.get_tree().set_pause(false)
		
		animator.play_backwards("fade_in")
		yield(animator,"finished")
		
		self.hide()
		self.set_process_input(false)
		
		#SoundManager.reset_track()
		#SoundManager.bgm_set_loop(true)
		if not SoundManager.bgm_stream.is_playing():
			SoundManager.play_bgm()
