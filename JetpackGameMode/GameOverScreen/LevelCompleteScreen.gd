class_name LevelCompletedScreen
extends Node2D

## Write your doc string for this file here

#region Member Variables and Dependencies ---------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------


var game: Game
var game_mode: String = "": set = _set_game_mode

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


#--- private variables - order: export > normal var > onready -------------------------------------

@export_file("*.tscn") var _main_menu_path: String
@export_file("*.tscn") var _options_path: String
@export_file("*.tscn") var _upgrade_path: String
@export_file("*.tscn") var _level_select_path: String

@onready var _replay_btn: BasicGameButton = $ResultsContainer/Buttons/Replay
@onready var _next_level_btn: BasicGameButton = $ResultsContainer/Buttons/NextLevel
@onready var _watch_ending_btn: BasicGameButton = $ResultsContainer/Buttons/WatchEnding
@onready var _upgrade_btn: BasicGameButton = $ResultsContainer/Buttons/Upgrade
@onready var _notification_circle: TextureRect = $ResultsContainer/Buttons/Upgrade/NotificationCircle
@onready var _level_select_btn: BasicGameButton = $ResultsContainer/Buttons/LevelSelect
@onready var _quit_btn: BasicGameButton = $ResultsContainer/Buttons/Quit
@onready var _animator: AnimationPlayer = $AnimationPlayer
@onready var _stage_number: Label = $StageClearedContainer/LevelText/StageNumber
@onready var _stage_name: Label = $StageClearedContainer/LevelText/StageName

var _last_focus: BasicGameButton = null

#endregion Member Variables and Dependencies ------------------------------------------------------


#region Built in Engine Methods -------------------------------------------------------------------

func _ready():
	_watch_ending_btn.hide()
	_animator.assigned_animation = "base"
	_animator.seek(0,true)
	
	score_results = $ResultsContainer/ScoreResults
	label_score = score_results.get_node("ScoreContainer/Score")
	label_highscore = score_results.get_node("HighScoreContainer/Highscore")
	upgrade_container = score_results.get_node("UpgradeContainer")
	label_upgrade = score_results.get_node("UpgradeContainer/UpgradePoints")
	score_congrats = score_results.get_node("ScoreContainer/HighscoreText")
	score_congrats.hide()
	
	unlock_results = $ResultsContainer/ModeUnlock
	time_results = $ResultsContainer/TimeResults
	label_time = time_results.get_node("TimeContainer/Time")
	label_hightime = time_results.get_node("HighTimeContainer/HighTime")
	time_congrats = time_results.get_node("TimeContainer/HightimeText")
	time_congrats.hide()
	
	if not _upgrade_btn.is_connected("focus_entered", Callable(self, "_on_focus_enter")):
		_upgrade_btn.connect("focus_entered", Callable(self, "_on_focus_enter"))
	
	if not _level_select_btn.is_connected("focus_entered", Callable(self, "_on_focus_enter")):
		_level_select_btn.connect("focus_entered", Callable(self, "_on_focus_enter"))
	
	if get_tree().current_scene == self:
		game_mode = "story"
		_animator.play("open")
		_quit_btn.grab_focus()
	else:
		await owner.ready
		game = get_parent().get_parent()
		game_mode = game.game_mode


func _unhandled_input(event) -> void:
	if not visible:
		return
	
	if event.is_action("ui_cancel"):
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("ui_cancel"):
		var focus_button: BasicGameButton = _quit_btn
		if focus_button.has_focus():
			_on_quit_pressed()
		else:
			focus_button.grab_focus()

#endregion Built in Engine Methods ----------------------------------------------------------------


#region Public Methods ----------------------------------------------------------------------------

func open(level_number: int, level_name: String):
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
	
	var to_focus: BasicGameButton = null
	if game_mode == "story":
		upgrade_container.show()
		upgrade_points = game.upgrade_points
		print_decimal(upgrade_points, label_upgrade)
		_notification_circle.set_notification_points(upgrade_points)
		
		var last_level = game.level_handler.get_levels_count()-1
		var current_level = Global.savedata["story"]["current level"]
		var unlocked_levels = Global.savedata["story"]["levels unlocked"]
		
		if current_level < last_level:
			if current_level == unlocked_levels:
				unlocked_levels = current_level + 1
				Global.update_story_unlocks(unlocked_levels)
				if unlocked_levels == 1:
					Global.update_story_last_unlock(unlocked_levels)
			to_focus = _next_level_btn
		else:
			_next_level_btn.hide()
			_watch_ending_btn.show()
			to_focus = _watch_ending_btn
	elif game_mode == "speedrun":
		upgrade_container.hide()
		_upgrade_btn.hide()
		
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
		
		to_focus = _replay_btn
	
	to_focus.grab_focus()
	show()
	if level_number > 0:
		_stage_number.set_text("STAGE %02d"%[level_number])
	else:
		_stage_number.hide()
	_stage_name.set_text(level_name)
	_animator.play("open")
	sfx_player.play()
	
	Global.achievements_handler.save()


## Called at the end of "open" animation
func play_unlock_animations():
	if get_tree().current_scene == self:
		return
	
	if game.is_last_stage() and not Global.is_story_completed():
		Global.story_completed()
		var unlock_animator = get_node("ResultsContainer/ModeUnlock/AnimationPlayer")
		unlock_animator.play("unlock")


func restart_game():
	if game != null:
		_animator.play("fade_out")
		ScreenManager.black_transition_replace("res://JetpackGameMode/JetpackGame.tscn")


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
	points_str = "%02d"%[points]
	label.set_text(points_str)


func print_time(runtime, label):
	var minutes = int(runtime/60)
	var seconds = int(runtime%60)
	
	if minutes < 10:
		minutes = "0%s"%[minutes]
	
	if seconds < 10:
		seconds = "0%s"%[seconds]
	
	label.set_text("%s:%s"%[minutes,seconds])

#endregion Public Methods -------------------------------------------------------------------------


#region Private Methods ---------------------------------------------------------------------------

func _set_game_mode(p_value: String) -> void:
	game_mode = p_value
	if game_mode == "story":
		_replay_btn.show()
		_upgrade_btn.show()
		_next_level_btn.show()
		_level_select_btn.show()
		_quit_btn.show()
		
		score_results.show()
		unlock_results.show()
		time_results.hide()
	elif game_mode == "speedrun":
		_replay_btn.show()
		_upgrade_btn.hide()
		_level_select_btn.hide()
		_next_level_btn.hide()
		_quit_btn.show()
		
		score_results.show()
		time_results.show()
		unlock_results.hide()
		
		_replay_btn.set_focus_neighbor(SIDE_LEFT, _quit_btn.get_path())
		_quit_btn.set_focus_neighbor(SIDE_RIGHT, _replay_btn.get_path())


func _on_replay_pressed():
	Global.is_retry = true
	restart_game()


func _on_quit_pressed():
	SoundManager.stop_bgm()
	ScreenManager.load_screen(_main_menu_path)


func _on_upgrade_pressed():
	var path = _upgrade_path
	_last_focus = _upgrade_btn
	_animator.play("fade_out")
	await _animator.animation_finished
	
	hide()
	ScreenManager.load_above(path, _last_focus, self)


func _on_focus_enter():
	#print("FOCUS GRABBED")
	if not visible:
		show()
		_animator.play_backwards("fade_out")
		await _animator.animation_finished
		
		upgrade_points = Global.savedata["story"]["upgrade points"]
		print_decimal(upgrade_points, label_upgrade)
		_notification_circle.set_notification_points(upgrade_points)


func _on_LevelSelect_pressed():
	var path = _level_select_path
	_last_focus = _level_select_btn
	_animator.play("fade_out")
	await _animator.animation_finished
	
	hide()
	ScreenManager.load_above(path, _last_focus, self)


func _on_NextLevel_pressed():
	Global.is_retry = false
	var level = Global.savedata["story"]["current level"] + 1
	
	if OS.has_feature("demo") and level > 5:
		var buy_screen_path = "res://CommonScenes/DemoThankYou/DemoThankYou.tscn"
		ScreenManager.black_transition(buy_screen_path, _next_level_btn, self, false)
	else:
		Global.set_current_story_level(level)
		restart_game()


func _on_WatchEnding_pressed() -> void:
	var ending_path: = "res://Cutscenes/Cutscene3.tscn"
	ScreenManager.black_transition(ending_path, null, self)

#endregion Private Methods ------------------------------------------------------------------------
