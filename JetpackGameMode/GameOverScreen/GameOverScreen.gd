extends Node2D

export(String, FILE) var main_menu_path

var replay_btn
var upgrade_btn
var level_select_btn
var quit_btn
var animator

var last_focus

var game
var game_mode

var score_results
var label_score
var label_highscore
var upgrade_points
var upgrade_container
var label_upgrade
var score_congrats

var time_results
var label_time
var label_hightime
var time_congrats

var laps_results
var label_laps
var label_highlaps
var laps_congrats

var upgrade_path = "res://CommonScenes/UpgradeMenu/UpgradeMenu.tscn"
var level_select_path = "res://CommonScenes/LevelSelectMenu/LevelSelectMenu.tscn"

func _ready():
	replay_btn = self.get_node("ResultsContainer/Buttons/Replay")
	upgrade_btn = self.get_node("ResultsContainer/Buttons/Upgrade")
	level_select_btn = self.get_node("ResultsContainer/Buttons/LevelSelect")
	quit_btn = self.get_node("ResultsContainer/Buttons/Quit")
	animator = self.get_node("AnimationPlayer")
	
	animator.assigned_animation = "base"
	animator.seek(0,true)
	
	score_results = self.get_node("ResultsContainer/ScoreResults")
	label_score = score_results.get_node("ScoreContainer/Score")
	label_highscore = score_results.get_node("HighScoreContainer/Highscore")
	upgrade_container = score_results.get_node("UpgradeContainer")
	label_upgrade = score_results.get_node("UpgradeContainer/UpgradePoints")
	score_congrats = score_results.get_node("ScoreContainer/HighscoreText")
	
	time_results = self.get_node("ResultsContainer/TimeResults")
	label_time = time_results.get_node("TimeContainer/Time")
	label_hightime = time_results.get_node("HighTimeContainer/HighTime")
	time_congrats = time_results.get_node("TimeContainer/HightimeText")
	
	laps_results = self.get_node("ResultsContainer/LapsResults")
	label_laps = laps_results.get_node("LapsContainer/Laps")
	label_highlaps = laps_results.get_node("HighLapsContainer/HighLaps")
	laps_congrats = laps_results.get_node("LapsContainer/HighlapsText")
	
	game = get_parent().get_parent()
	game_mode = game.game_mode
#	replay_btn.grab_focus()
	
	if not upgrade_btn.is_connected("focus_entered",self,"_on_focus_enter"):
		upgrade_btn.connect("focus_entered",self,"_on_focus_enter")
	
	if game_mode == "story":
		replay_btn.show()
		upgrade_btn.show()
		level_select_btn.show()
		quit_btn.show()
		
		score_results.show()
		time_results.hide()
		laps_results.hide()
	elif game_mode == "arcade":
		replay_btn.show()
		upgrade_btn.hide()
		level_select_btn.hide()
		quit_btn.show()
		
		score_results.show()
		time_results.hide()
		laps_results.show()
		
		replay_btn.set_focus_neighbour(MARGIN_LEFT, quit_btn.get_path())
		quit_btn.set_focus_neighbour(MARGIN_RIGHT, replay_btn.get_path())
	elif game_mode == "speedrun":
		replay_btn.show()
		upgrade_btn.hide()
		level_select_btn.hide()
		quit_btn.show()
		
		score_results.show()
		time_results.show()
		laps_results.hide()
		
		replay_btn.set_focus_neighbour(MARGIN_LEFT, quit_btn.get_path())
		quit_btn.set_focus_neighbour(MARGIN_RIGHT, replay_btn.get_path())


func open():
	var score = game.get_score()
	print_score(score, label_score)
	
	var highscore = game.highscore
	print_score(highscore, label_highscore)
	
	if score > highscore:
		score_congrats.show()
		game.highscore = score
		Global.update_highscore(game_mode, score)
	
	if game_mode == "story":
		upgrade_container.show()
		upgrade_points = game.upgrade_points
		print_decimal(upgrade_points, label_upgrade)
	elif game_mode == "speedrun":
		upgrade_container.hide()
		
		var time = game.get_time()
		print_time(time, label_time)
		
		var hightime = game.hightime
		print_time(hightime, label_hightime)
	elif game_mode == "arcade":
		upgrade_container.hide()
		
		var laps = game.get_laps()
		print_decimal(laps, label_laps)
		
		var highlaps = game.highlaps
		print_decimal(highlaps, label_highlaps)
		
		if laps > highlaps:
			laps_congrats.show()
			game.highlaps = laps
			Global.update_highlaps(laps)
	
	self.show()
	animator.play("open")
	
	#SoundManager.bgm_set_loop(false)
	#SoundManager.stop_bgm()
	
	game.set_game_state("GameOver")
	get_tree().set_pause(true)
	replay_btn.grab_focus()

func _on_replay_pressed():
	if game != null:
		animator.play("fade out")
		ScreenManager.black_transition_replace("res://JetpackGameMode/JetpackGame.tscn")
		Global.is_retry = true

func _on_quit_pressed():
	SoundManager.stop_bgm()
	ScreenManager.load_screen(main_menu_path)


func resume_game():
	self.hide()
	get_tree().set_pause(false)

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
	animator.play("fade out")
	yield(animator, "animation_finished")
	
	self.hide()
	ScreenManager.load_above(path, last_focus, self)


func _on_focus_enter():
	#print("FOCUS GRABBED")
	if not visible:
		self.show()
		animator.play_backwards("fade out")
		yield(animator, "animation_finished")
		
		if SoundManager.bgm_stream.is_paused():
			SoundManager.pause_bgm()
		
		upgrade_points = Global.savedata["story"]["upgrade points"]
		print_decimal(upgrade_points, label_upgrade)
		

func _on_LevelSelect_pressed():
	var path = level_select_path
	last_focus = level_select_btn.get_path()
	animator.play("fade out")
	yield(animator, "animation_finished")
	
	self.hide()
	ScreenManager.load_above(path, last_focus, self)
