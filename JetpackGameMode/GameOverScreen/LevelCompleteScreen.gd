extends Node2D

export(String, FILE) var main_menu_path

var replay_btn
var next_level_btn
var watch_ending_btn
var upgrade_btn
var level_select_btn
var quit_btn
var animator

var last_focus

var game
var game_mode
var stage_number
var stage_name

var score_results
var label_score
var label_highscore
var upgrade_points
var upgrade_container
var label_upgrade
var score_congrats

var unlock_results
var time_results
var label_time
var label_hightime
var time_congrats

var options_path = "res://CommonScenes/OptionsMenu/OptionsMenuScreen.tscn"
var upgrade_path = "res://CommonScenes/UpgradeMenu/UpgradeMenu.tscn"
var level_select_path = "res://CommonScenes/LevelSelectMenu/LevelSelectMenu.tscn"

func _ready():
	replay_btn = $ResultsContainer/Buttons/Replay
	next_level_btn = $ResultsContainer/Buttons/NextLevel
	watch_ending_btn = $ResultsContainer/Buttons/WatchEnding
	upgrade_btn = $ResultsContainer/Buttons/Upgrade
	level_select_btn = $ResultsContainer/Buttons/LevelSelect
	quit_btn = $ResultsContainer/Buttons/Quit
	animator = $AnimationPlayer
	stage_number = $StageClearedContainer/LevelText/StageNumber
	stage_name = $StageClearedContainer/LevelText/StageName
	
	watch_ending_btn.hide()
	animator.assigned_animation = "base"
	animator.seek(0,true)
	
	score_results = $ResultsContainer/ScoreResults
	label_score = score_results.get_node("ScoreContainer/Score")
	label_highscore = score_results.get_node("HighScoreContainer/Highscore")
	upgrade_container = score_results.get_node("UpgradeContainer")
	label_upgrade = score_results.get_node("UpgradeContainer/UpgradePoints")
	score_congrats = score_results.get_node("ScoreContainer/HighscoreText")
	
	unlock_results = $ResultsContainer/ModeUnlock
	time_results = $ResultsContainer/TimeResults
	label_time = time_results.get_node("TimeContainer/Time")
	label_hightime = time_results.get_node("HighTimeContainer/HighTime")
	time_congrats = time_results.get_node("TimeContainer/HightimeText")
	
	game = get_parent().get_parent()
	game_mode = game.game_mode
	
	if not upgrade_btn.is_connected("focus_entered",self,"_on_focus_enter"):
		upgrade_btn.connect("focus_entered",self,"_on_focus_enter")
	
	if not level_select_btn.is_connected("focus_entered",self,"_on_focus_enter"):
		level_select_btn.connect("focus_entered",self,"_on_focus_enter")
	
	
	if game_mode == "story":
		replay_btn.show()
		upgrade_btn.show()
		next_level_btn.show()
		level_select_btn.show()
		quit_btn.show()
		
		score_results.show()
		unlock_results.show()
		time_results.hide()
	elif game_mode == "speedrun":
		replay_btn.show()
		upgrade_btn.hide()
		level_select_btn.hide()
		next_level_btn.hide()
		quit_btn.show()
		
		score_results.show()
		time_results.show()
		unlock_results.hide()
		
		replay_btn.set_focus_neighbour(MARGIN_LEFT, quit_btn.get_path())
		quit_btn.set_focus_neighbour(MARGIN_RIGHT, replay_btn.get_path())


func _unhandled_input(event) -> void:
	if not visible:
		return
	
	if event.is_action("ui_cancel"):
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("ui_cancel"):
		var focus_button: Button = quit_btn
		if focus_button.has_focus():
			_on_quit_pressed()
		else:
			focus_button.grab_focus()


func open(level_number, level_name):
	if game.get_game_state() == 3:
		Global.tutorial_completed()
	
	var sfx_player = $SfxLibrary/LevelComplete
	
	game.set_game_state("GameOver")
	get_tree().set_pause(true)
	
	SoundManager.bgm_set_loop(false)
	#SoundManager.stop_bgm()
	
	var score = game.get_score()
	print_score(score, label_score)
	
	var highscore = game.highscore
	print_score(highscore, label_highscore)
	
	if score > highscore:
		score_congrats.show()
		game.highscore = score
		Global.update_highscore(game_mode, score)
		
		sfx_player = $SfxLibrary/LevelCompleteHighscore
	else:
		score_congrats.hide()
	
	if game_mode == "story":
		upgrade_container.show()
		upgrade_points = game.upgrade_points
		print_decimal(upgrade_points, label_upgrade)
		
		var last_level = game.level_loader.get_max_levels()-1
		var current_level = Global.savedata["story"]["current level"]
		var unlocked_levels = Global.savedata["story"]["levels unlocked"]
		
		if current_level < last_level:
			if current_level == unlocked_levels:
				unlocked_levels = current_level + 1
				Global.update_story_unlocks(unlocked_levels)
				if unlocked_levels == 1:
					Global.update_story_last_unlock(unlocked_levels)
			next_level_btn.grab_focus()
		else:
			next_level_btn.hide()
			watch_ending_btn.show()
			watch_ending_btn.grab_focus()
	elif game_mode == "speedrun":
		upgrade_container.hide()
		upgrade_btn.hide()
		
		var time = game.get_time()
		print_time(time, label_time)
		
		var hightime = game.hightime
		print_time(hightime, label_hightime)
		
		if time < hightime or hightime == 0:
			time_congrats.show()
			game.hightime = time
			Global.update_hightime(time)
		else:
			time_congrats.hide()
		
		replay_btn.grab_focus()
	
	self.show()
	if level_number > 0:
		stage_number.set_text("STAGE %02d"%[level_number])
	else:
		stage_number.hide()
	stage_name.set_text(level_name)
	animator.play("open")
	sfx_player.play()
	
	Global.achievements_handler.save()


func play_unlock_animations():
	"""
	Called at the end of "open" animation
	"""
	if game.is_last_stage() and not Global.is_story_completed():
		Global.story_completed()
		var unlock_animator = get_node("ResultsContainer/ModeUnlock/AnimationPlayer")
		unlock_animator.play("unlock")


func _on_replay_pressed():
	Global.is_retry = true
	restart_game()


func restart_game():
	if game != null:
		animator.play("fade_out")
		ScreenManager.black_transition_replace("res://JetpackGameMode/JetpackGame.tscn")


func _on_quit_pressed():
	SoundManager.stop_bgm()
	ScreenManager.load_screen(main_menu_path)

func print_score(points, label):
	var points_str
	if points < 10:
		points_str = "000"+str(points)
	elif points < 100:
		points_str = "00"+str(points)
	elif points < 1000:
		points_str = "0"+str(points)
	else:
		points_str = str(points)
	label.set_text(points_str)

func print_decimal(points, label):
	var points_str
	if points < 10:
		points_str = "0"+str(points)
	else:
		points_str = str(points)
	label.set_text(points_str)

func print_time(runtime, label):
	var minutes = int(runtime/60)
	var seconds = int(runtime%60)
	
	if minutes < 10:
		minutes = "0%s"%[minutes]
	
	if seconds < 10:
		seconds = "0%s"%[seconds]
	
	label.set_text("%s:%s"%[minutes,seconds])

func _on_upgrade_pressed():
	var path = upgrade_path
	last_focus = upgrade_btn
	animator.play("fade_out")
	yield(animator, "animation_finished")
	
	self.hide()
	ScreenManager.load_above(path, last_focus, self)


func _on_focus_enter():
	#print("FOCUS GRABBED")
	if not self.visible:
		self.show()
		animator.play_backwards("fade_out")
		yield(animator, "animation_finished")
		
		upgrade_points = Global.savedata["story"]["upgrade points"]
		print_decimal(upgrade_points, label_upgrade)
		

func _on_LevelSelect_pressed():
	var path = level_select_path
	last_focus = level_select_btn.get_path()
	animator.play("fade_out")
	yield(animator, "animation_finished")
	
	self.hide()
	ScreenManager.load_above(path, last_focus, self)


func _on_NextLevel_pressed():
	Global.is_retry = false
	var level = Global.savedata["story"]["current level"] + 1
	Global.set_current_story_level(level)
	 
	restart_game()


func _on_WatchEnding_pressed() -> void:
	var ending_path: = "res://Cutscenes/Cutscene3.tscn"
	ScreenManager.black_transition(ending_path, null, self)
