class_name Game
extends Node2D

## Main Game Scene and script.

#region Member Variables and Dependencies ---------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const MAX_SPEED_INCREMENT_PER_LAP = 1
const STATE = {
	"Playing": 0,
	"Start": 1,
	"Pause": 2,
	"Tutorial": 3,
	"GameOver": 4,
	"Cutscene": 5
}

#--- public variables - order: export > normal var > onready --------------------------------------

# Nodes this script will interact with
@export var path_player: NodePath = NodePath()
@export var path_final_boss: NodePath = NodePath()
@export var path_camera: NodePath = NodePath()

# Game Mode "Stats" and Variables?
@export var point_multiple = 5
@export var upgrade_multiple = 30
@export_file var level_select_path = "res://CommonScenes/LevelSelectMenu/LevelSelectMenu.tscn"
@export_file var upgrade_path = "res://CommonScenes/UpgradeMenu/UpgradeMenu.tscn"

@export_category("Editor Debug")
@export var force_test_mode := false
@export_enum("story", "arcade", "speedrun") var test_mode = "story"
@export var test_level_or_points: int = 0

var score_label
var points_label
var time_laps_label
var runtime_label
var upgrade_label
var upgrade_messager
var speed_messager
var ammunition
var hud_animator
var player
var camera
var object_spawner
var parallax_background
var active_background_bosses = []

# Other "Game Screens"
var game_over_screen
var level_complete_screen
var countdown
var tutorial

var last_level_choice
var points = 0
var points_level = 0
var multiples_level = upgrade_multiple
var arcade_laps = 0

var current_level_index: int = -1
var current_level: Level = null

var highscore
var highlaps
var hightime

var initial_shield
var initial_ammo
var initial_speed
var max_speed
var laser_strength
var next_upgrade
var upgrade_points
var levels_unlocked
var cooldown
var multiplyer = 1

var current_state = STATE["Start"]

@onready var game_settings = Global.get_game_mode()
@onready var game_mode = game_settings["game mode"]
@onready var category = game_settings["sub-mode"]
@onready var level_handler: LevelHandler = $LevelHandler

#--- private variables - order: export > normal var > onready -------------------------------------

#endregion Member Variables and Dependencies ------------------------------------------------------


#region Built in Engine Methods -------------------------------------------------------------------

func _init():
	Global.game = self


func _ready():
	#TODO? - Change the nodes according to game mode?
	tutorial = get_node("AboveScreen/TutorialTipScreen")
	game_over_screen = get_node("AboveScreen/GameOverScreen")
	level_complete_screen = get_node("AboveScreen/LevelCompleteScreen")
	
	# Nodes
	countdown = get_node("AboveScreen/CountdownScreen")
	ammunition = get_node("HUD/Meters/Ammunition")
	score_label = get_node("HUD/CenterArea/Score")
	points_label = get_node("HUD/CenterArea/Points")
	time_laps_label = get_node("HUD/CenterArea/TimeLaps")
	runtime_label = get_node("HUD/CenterArea/RunTime")
	upgrade_label = get_node("HUD/UpgradeLabel")
	upgrade_messager = get_node("HUD/UpgradeLabel/Messager")
	speed_messager = get_node("HUD/SpeedLabel")
	hud_animator = get_node("HUD/AnimationPlayer")
	player = get_node(path_player)
	camera = get_node(path_camera)
	object_spawner = get_node("RawLayer/WorldVieport/SubViewport/Obstaculos/ObstacleSpawner")
	parallax_background = get_node("RawLayer/WorldVieport/SubViewport/ParallaxBackground")
	
	show_pre_game()


func _input(event):
	if event.is_action_pressed("debug_win_level") and current_state == STATE.Playing \
			and OS.is_debug_build():
		level_completed()

#endregion Built in Engine Methods ----------------------------------------------------------------


#region Public Methods ----------------------------------------------------------------------------

func show_pre_game():
	print("JetpackGame.gd | Game Mode: %s | Is Retry: %s"%[game_mode, Global.is_retry])
	
	if force_test_mode:
		print("JetpackGame.gd | Test Mode: %s | Test Sub: %s"%[test_mode, test_level_or_points])
		game_mode = test_mode
		Global.savedata["state"]["game mode"] = test_mode
		if test_mode == "story":
			category = "level selected"
			Global.savedata["state"]["sub-mode"] = "level selected"
			Global.savedata["story"]["current level"] = test_level_or_points
		else:
			category = str(test_level_or_points)
			Global.savedata["state"]["sub-mode"] = str(test_level_or_points)
			Global.reset_category_progress(Global.savedata.state)
	
	if game_mode == "story":
		time_laps_label.hide()
		runtime_label.hide()
		load_story_pregame()
	elif game_mode == "arcade" or game_mode == "speedrun":
		if game_mode == "arcade":
			time_laps_label.show()
			runtime_label.hide()
		elif game_mode == "speedrun":
			time_laps_label.show()
			runtime_label.show()
		load_upgrade_pregame()
	else:
		print("ERROR | Invalid game mode: %s"%[game_mode])
	
	self.get_tree().set_pause(true)


func load_story_pregame():
	#if not is_tutorial_completed():
	#	Global.set_current_story_level(0)
	
	if category == "level selected":
		game_start()
	elif category == "select level":
		var path = level_select_path
		ScreenManager.load_above(path, self, self)
	else:
		print("ERROR | Invalid sub-mode: %s"%[game_settings])


func is_tutorial_completed():
	return Global.savedata["story"]["tutorial beaten"]


func load_upgrade_pregame():
	if category.is_valid_int():
		ScreenManager.load_above(upgrade_path, self, self)
	else:
		print("ERROR | Invalid sub-mode: %s"%[game_settings])


func game_start():
	current_level = null
	initialize_game_stats()
	setup_game_mode_level()
	
	player.set_player_stats(current_level.is_tutorial and not is_tutorial_completed())
	ammunition.initialize_ammo(initial_ammo)
	
	if not current_level.intro_cutscene.is_empty() and not Global.is_retry:
		set_game_state("Cutscene")
		ScreenManager.black_transition(current_level.intro_cutscene, null, self)
		if not ScreenManager.scene_above_loaded.is_connected(_on_intro_cutscene_loaded):
			ScreenManager.scene_above_loaded.connect(_on_intro_cutscene_loaded, CONNECT_ONE_SHOT)
	else:
		start_countdown()


func start_countdown():
	if current_level.is_tutorial:
		set_game_state("Tutorial")
		tutorial.play(current_level_index, current_level.title)
		object_spawner.connect_tutorial_signal(tutorial)
	else:
		if game_mode == "story":
			countdown.set_story_text(current_level_index, current_level.title)
		elif game_mode == "arcade":
			countdown.set_arcade_text(current_level.title)
		elif game_mode == "speedrun":
			countdown.set_speedrun_text(current_level.title)
		countdown.play()


#called from CountdownScreen, after any Pre Game has been cleared
func initialize_game_stats(): 
	if game_mode == "story":
		current_level_index = Global.savedata["story"]["current level"]
		highscore = Global.savedata[game_mode]["highscore"][current_level_index]
		initial_shield = Global.savedata[game_mode]["initial shield"]
		initial_ammo = Global.savedata[game_mode]["initial ammo"]
		initial_speed = Global.savedata[game_mode]["initial speed"]
		max_speed = player.min_speed + Global.savedata[game_mode]["max speed"]
		laser_strength = Global.savedata[game_mode]["laser strength"]
		next_upgrade = Global.savedata[game_mode]["next upgrade"]
		upgrade_points = Global.savedata[game_mode]["upgrade points"]
		levels_unlocked = Global.savedata[game_mode]["levels unlocked"]
		cooldown = Global.savedata[game_mode]["cooldown"]
	
	elif game_mode == "arcade" or game_mode == "speedrun":
		if game_mode == "arcade":
			highlaps = Global.savedata[game_mode]["highlaps"]
		elif game_mode == "speedrun":
			hightime = Global.savedata[game_mode]["hightime"]
		
		highscore = Global.savedata[game_mode]["highscore"]
		initial_shield = Global.savedata[game_mode]["initial shield"]
		initial_ammo = Global.savedata[game_mode]["initial ammo"]
		initial_speed = Global.savedata[game_mode]["initial speed"]
		max_speed = 4 + Global.savedata[game_mode]["max speed"]
		laser_strength = Global.savedata[game_mode]["laser strength"]
		cooldown = Global.savedata[game_mode]["cooldown"]


func setup_game_mode_level():
	if game_mode == "story":
		print("JetpackGame.gd | current level: %s"%current_level_index)
		if not valid_level_choice(current_level_index):
			print("ERROR | LEVEL OUT OF RANGE")
			current_level_index = level_handler.get_levels_count()-1
		
		current_level = load_level(current_level_index)
	elif game_mode == "arcade":
		current_level = load_level(1, true, true)
		current_level.title = "How many laps can you survive?"
	elif game_mode == "speedrun":
		current_level = load_level(1, true)
		current_level.title = "Gotta Go Fast!"


func valid_level_choice(p_index: int):
	return p_index >= 0 and p_index < level_handler.get_levels_count()


func reset_background_bosses_list():
	active_background_bosses = []


func restart_background_bosses_count():
	for boss in active_background_bosses:
		boss.restart_count()


func load_level(level_choice, load_all = false, loop = false):
	var level: Level = level_handler.load_level(level_choice, load_all, loop)
	object_spawner.set_level(level)
	
	reset_background_bosses_list()
	if level.bosses.size() > 0:
		var boss_node: Node2D = null
		for boss_data: BossData in level.bosses:
			if boss_data.boss_type == LevelData.BossTypes.Boss:
				boss_node = get_node(path_final_boss)
				boss_node.set_boss_data(boss_data)
			else:
				boss_node = parallax_background.set_background_bosses(boss_data)
				
			if boss_node != null:
				if not object_spawner.is_connected("beat_spawned", Callable(boss_node, "_on_beat_spawned")):
					object_spawner.connect("beat_spawned", Callable(boss_node, "_on_beat_spawned"))
				active_background_bosses.append(boss_node)
	
	if game_mode == "arcade":
		set_laps(arcade_laps)
	
	return level


func set_game_state(string):
	current_state = STATE[string]
	if current_state == STATE.Pause:
		SoundManager.mute_game_sfx()
	else:
		SoundManager.unmute_game_sfx()


func get_game_state():
	return current_state


func get_score():
	return points


func get_laps():
	return arcade_laps


func get_time():
	return runtime_label.run_time


func game_over():
	if game_mode == "story":
		Global.update_story_next_upgrade(next_upgrade)
	hud_animator.play("fade_out")
	game_over_screen.open()
	get_tree().set_pause(true)


func update_score():
	var points_str = "%04d"%[points]
	points_label.set_text(points_str)


func level_completed():
	const SPEEDRUN_TITLE = "Speedrun Track"
	if game_mode == "story":
		Global.update_story_next_upgrade(next_upgrade)
	hud_animator.play("fade_out")
	if game_mode == "story":
		level_complete_screen.open(current_level_index, current_level.title)
	elif game_mode == "speedrun":
		level_complete_screen.open(-1, SPEEDRUN_TITLE)


func player_reset_y():
	hud_animator.play_backwards("fade_out")
	player.reset_y()
	
	var boost_timer = get_node("AutoBoost")
	Input.action_press("boost")
	boost_timer.start()
	await boost_timer.timeout
	Input.action_release("boost")


func set_laps(lap_count):
	time_laps_label.set_text("Laps: %s"%[lap_count])


func is_last_stage():
	if current_level_index == level_handler.get_levels_count()-1:
		return true
	else:
		return false

#endregion Public Methods -------------------------------------------------------------------------


#region Private Methods ---------------------------------------------------------------------------

func _on_intro_cutscene_loaded(loaded_cutscene: Cutscene):
	if not loaded_cutscene.cutscene_ended.is_connected(_on_intro_cutscene_finished):
		loaded_cutscene.cutscene_ended.connect(_on_intro_cutscene_finished, CONNECT_ONE_SHOT)


func _on_intro_cutscene_finished():
	if not ScreenManager.transition_ended.is_connected(start_countdown):
		ScreenManager.transition_ended.connect(start_countdown, CONNECT_ONE_SHOT)


func _on_scored(num):
	var last_point_level = points_level
	#print("LPL: %s | LML: %s"%[last_point_level, last_multiple_level])
	points += round(num*multiplyer)
	points_level = int(points/(point_multiple*multiplyer))
	multiples_level -= 1
	#print("PL: %s | ML: %s"%[points_level, multiples_level])
	
	if points_level > last_point_level:
		if not ammunition.is_maxed_out():
			ammunition.add_ammo()
			player.charge_ammo()
		
		print("initial_speed: %s | max_speed: %s"%[player.speed_x, max_speed])
		if player.speed_x < max_speed:
			player.speed_x += 1.0
			player.gravity += 10.0
			player.speed_y -= 20.0
			if player.speed_x == max_speed:
				speed_messager.play_max_speed_message()
			else:
				speed_messager.play_accelerating_message()
			#print("speed_x: %s | gravity: %s | speed_y: %s"%[player.speed_x, player.gravity, player.speed_y])
			if not player.dashing:
				player.speed.x = player.speed_x* player.unit.x
	#			print(player.speed.x)
	
	if multiples_level <= 0:
		if game_mode == "arcade" or game_mode == "speedrun":
			multiplyer += 1
			
			score_label.set_text("Score %sx"%[multiplyer])
			upgrade_label.set_text("%sx Multiplyer"%[multiplyer])
			upgrade_messager.play("text_anim")
			multiples_level =  multiplyer * 0.5 * upgrade_multiple
			print("Next Multiplyer: %s"%[multiples_level])
			pass
	
	if game_mode == "story":
		next_upgrade -= num
		if next_upgrade <= 0 and Global.savedata["story"]["upgrade level"] < Global.max_upgrade_level:
			upgrade_points += 1
			upgrade_label.set_text("+ UPGRADE POINT!")
			upgrade_messager.play("text_anim")
			Global.update_story_upgrade(upgrade_points)
			next_upgrade = Global.savedata["story"]["next upgrade"]
	
	update_score()
	pass # replace with function body


func _on_ObstacleSpawner_level_end():
	if game_mode == "story":
		if not current_level.end_cutscene.is_empty():
			set_game_state("Cutscene")
			ScreenManager.black_transition(current_level.end_cutscene, null, self)
			if not ScreenManager.scene_above_loaded.is_connected(_on_end_cutscene_loaded):
				ScreenManager.scene_above_loaded.connect(_on_end_cutscene_loaded, CONNECT_ONE_SHOT)
		else:
			level_completed()
	elif game_mode == "speedrun":
		level_completed()
	elif game_mode == "arcade":
		arcade_laps += 1
		restart_background_bosses_count()
		load_level(1, true, true)
	else:
		printerr("ERROR | Invalid Game Mode: %s"%[game_settings])


func _on_end_cutscene_loaded(loaded_cutscene: Cutscene):
	if not loaded_cutscene.cutscene_ended.is_connected(_on_end_cutscene_finished):
		loaded_cutscene.cutscene_ended.connect(_on_end_cutscene_finished, CONNECT_ONE_SHOT) 
	#print("JetpackGame.gd | CUTSCENE LOADED | END SIGNAL CONNECTED")


func _on_end_cutscene_finished():
	if not ScreenManager.transition_ended.is_connected(level_completed):
		ScreenManager.transition_ended.connect(level_completed, CONNECT_ONE_SHOT)
	#print("JetpackGame.gd | CUTSCENE ENDED | TRANSITION SIGNAL CONNECTED")
	player.gravity_force = 0
	player.jetpack_force = 0

#endregion Private Methods ------------------------------------------------------------------------
