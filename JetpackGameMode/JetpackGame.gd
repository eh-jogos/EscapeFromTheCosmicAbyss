extends Node2D

const MAX_SPEED_INCREMENT_PER_LAP = 5

# Nodes this script will interact with
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
var level_loader
var camera
var object_spawner
var parallax_background
var active_background_bosses = []


# Other "Game Screens"
var game_over_screen
var level_complete_screen
var countdown
var tutorial

# Game Mode "Stats" and Variables?
export var point_multiple = 5
export var upgrade_multiple = 30
export(String, FILE) var level_select_path = "res://CommonScenes/LevelSelectMenu/LevelSelectMenu.tscn"
export(String, FILE) var upgrade_path = "res://CommonScenes/UpgradeMenu/UpgradeMenu.tscn"
export(String, "story", "arcade", "speedrun") var test_mode = "story"
export(int) var test_level_or_points = 0


var game_settings = Global.get_game_mode()
var game_mode = game_settings["game mode"]
var category = game_settings["sub-mode"]
var last_level_choice
var points = 0
var points_level = 0
var multiples_level = 0
var arcade_laps = 0
var level_num
var level_title
var level_intro_cutscene = null
var level_end_cutscene = null
var is_tutorial = false

var current_level
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

const STATE = {
	"Playing": 0,
	"Start": 1,
	"Pause": 2,
	"Tutorial": 3,
	"GameOver": 4,
	"Cutscene": 5
}

var current_state = STATE["Start"]

func _ready():
	#TODO? - Change the nodes according to game mode?
	tutorial = self.get_node("AboveScreen/TutorialTipScreen")
	game_over_screen = self.get_node("AboveScreen/GameOverScreen")
	level_complete_screen = self.get_node("AboveScreen/LevelCompleteScreen")
	
	# Nodes
	countdown = self.get_node("AboveScreen/CountdownScreen")
	ammunition = self.get_node("HUD/Meters/Ammunition")
	score_label = self.get_node("HUD/CenterArea/Score")
	points_label = self.get_node("HUD/CenterArea/Points")
	time_laps_label = self.get_node("HUD/CenterArea/TimeLaps")
	runtime_label = self.get_node("HUD/CenterArea/RunTime")
	upgrade_label = self.get_node("HUD/UpgradeLabel")
	upgrade_messager = self.get_node("HUD/UpgradeLabel/Messager")
	speed_messager = self.get_node("HUD/SpeedLabel")
	hud_animator = self.get_node("HUD/AnimationPlayer")
	player = self.get_node("Player")
	level_loader = self.get_node("LevelLoader")
	camera = self.get_node("Camera2D")
	object_spawner = camera.get_node("ObstacleSpawner")
	parallax_background = self.get_node("ParallaxBackground")
	
	show_pre_game()


func show_pre_game():
	print("JetpackGame.gd | Game Mode: %s | Is Retry: %s"%[game_mode, Global.is_retry])
	
	if game_mode == "test_mode":
		print("JetpackGame.gd | Test Mode: %s | Test Sub: %s"%[test_mode, test_level_or_points])
		game_mode = test_mode
		Global.savedata["state"]["game mode"] = test_mode
		if test_mode == "story":
			category = "level selected"
			Global.savedata["state"]["sub-mode"] = "level selected"
			Global.savedata["story"]["current level"] = test_level_or_points
		else:
			category = String(test_level_or_points)
			Global.savedata["state"]["sub-mode"] = String(test_level_or_points)
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
	if category.is_valid_integer():
		ScreenManager.load_above(upgrade_path, self, self)
	else:
		print("ERROR | Invalid sub-mode: %s"%[game_settings])

func game_start():
	initialize_game_stats()
	setup_game_mode_level()
	
	if level_intro_cutscene != null and not Global.is_retry:
		set_game_state("Cutscene")
		ScreenManager.black_transition(level_intro_cutscene, null, self)
		if not ScreenManager.is_connected("scene_above_loaded", self, "_on_intro_cutscene_loaded"):
			 ScreenManager.connect("scene_above_loaded", self, "_on_intro_cutscene_loaded", [], CONNECT_ONESHOT)
	else:
		start_countdown()


func _on_intro_cutscene_loaded(loaded_cutscene):
	if not loaded_cutscene.is_connected("cutscene_ended", self, "_on_intro_cutscene_finished"):
		loaded_cutscene.connect("cutscene_ended", self, "_on_intro_cutscene_finished", [], CONNECT_ONESHOT)


func _on_intro_cutscene_finished():
	if not ScreenManager.is_connected("transition_ended", self, "start_countdown"):
		ScreenManager.connect("transition_ended", self, "start_countdown", [], CONNECT_ONESHOT)

func start_countdown():
	if is_tutorial:
		set_game_state("Tutorial")
		tutorial.play(level_num, level_title)
		object_spawner.connect_tutorial_signal(tutorial)
	else:
		countdown.play(level_num, level_title)


#called from CountdownScreen, after any Pre Game has been cleared
func initialize_game_stats(): 
	if game_mode == "story":
		current_level = Global.savedata["story"]["current level"]
		highscore = Global.savedata[game_mode]["highscore"][current_level]
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
	
	player.set_player_stats()
	ammunition.initialize_ammo(initial_ammo)

func setup_game_mode_level():
	if game_mode == "story":
		print("JetpackGame.gd | current level: %s"%current_level)
		if not valid_level_choice(current_level):
			print("ERROR | LEVEL OUT OF RANGE")
			current_level = level_loader.get_max_levels()-1
		
		var level = load_level(current_level)
		level_num = current_level
		level_title = level.title
		
		if level.tutorial:
			is_tutorial = true
		
		if level.intro_cutscene:
			level_intro_cutscene = level.intro_cutscene
		#print("JetPackGame.gd | Intro? %s"%[level_intro_cutscene])
		
		if level.end_cutscene:
			level_end_cutscene = level.end_cutscene
		#print("JetPackGame.gd | End? %s"%[level_end_cutscene])
	
	elif game_mode == "arcade":
		level_num = "Arcade Arena!"
		level_title = "How many laps can you survive?"
	elif game_mode == "speedrun":
		level_num = "Speedrun Track!"
		level_title = "Gotta Go Fast!"

func valid_level_choice(level_to_check):
	return level_to_check < level_loader.get_max_levels()


func reset_background_bosses_list():
	active_background_bosses = []


func restart_background_bosses_count():
	for boss in active_background_bosses:
		boss.restart_count()


func load_level(level_choice, load_all = false, loop = false):
	var level = level_loader.load_level(level_choice, load_all, loop)
	object_spawner.set_level(level)
	
	reset_background_bosses_list()
	if level.has("bosses_nodes") and level.bosses_nodes.keys().size() > 0:
		for key in level.bosses_nodes.keys():
			var boss_node
			var laser_countdowns = level.bosses_nodes[key].laser_countdowns
			var animation_countdowns = level.bosses_nodes[key].animation_countdowns
			var animations = level.bosses_nodes[key].animations
			
			if level.bosses_nodes[key].is_a_boss_level:
				boss_node = get_node("Camera2D/FinalBoss/Boss")
				boss_node.set_boss_data(laser_countdowns, animation_countdowns, animations)
			else:
				boss_node = parallax_background.set_background_bosses(key, laser_countdowns, animation_countdowns, animations)
				
			if boss_node != null:
				if not object_spawner.is_connected("beat_spawned", boss_node, "_on_beat_spawned"):
					object_spawner.connect("beat_spawned", boss_node, "_on_beat_spawned")
				active_background_bosses.append(boss_node)
	
	if game_mode == "arcade":
		set_laps(arcade_laps)
	
	return level


func set_game_state(string):
	current_state = STATE[string]
	if current_state != STATE.Playing:
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

func _on_scored(num):
	var last_point_level = points_level
	var last_multiple_level = multiples_level
	#print("LPL: %s | LML: %s"%[last_point_level, last_multiple_level])
	points += (num*multiplyer)
	points_level = int(points/(point_multiple*multiplyer))
	if multiplyer <= 1:
		multiples_level = int(points/(upgrade_multiple))
	else:
		multiples_level = int(points/(upgrade_multiple+(upgrade_multiple*multiplyer)))
	#print("PL: %s | ML: %s"%[points_level, multiples_level])
	
	if points_level > last_point_level:
		ammunition.add_ammo()
		
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
	
		if multiples_level > last_multiple_level:
			if game_mode == "arcade" or game_mode == "speedrun":
				multiplyer += 1
				
				score_label.set_text("Score %sx"%[multiplyer])
				upgrade_label.set_text("%sx Multiplyer"%[multiplyer])
				upgrade_messager.play("text_anim")
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

func update_score():
	var points_str
	if points < 10:
		points_str = "000"+str(points)
	elif points < 100:
		points_str = "00"+str(points)
	elif points < 1000:
		points_str = "0"+str(points)
	else:
		points_str = str(points)
	points_label.set_text(points_str)

func dash_score():
	points -= 5
	update_score()

func tutorial_start():
	tutorial.play()

func _on_ObstacleSpawner_level_end():
	if game_mode == "story":
		if level_end_cutscene != null:
			set_game_state("Cutscene")
			ScreenManager.black_transition(level_end_cutscene, null, self)
			if not ScreenManager.is_connected("scene_above_loaded", self, "_on_end_cutscene_loaded"):
				ScreenManager.connect("scene_above_loaded", self, "_on_end_cutscene_loaded", [], CONNECT_ONESHOT)
		else:
			level_completed()
	elif game_mode == "speedrun":
		level_completed()
	elif game_mode == "arcade":
		arcade_laps += 1
		max_speed += MAX_SPEED_INCREMENT_PER_LAP
		speed_messager.play_max_speed_increased_message()
		restart_background_bosses_count()
		load_level(1, true)
	else:
		printerr("ERROR | Invalid Game Mode: %s"%[game_settings])


func _on_end_cutscene_loaded(loaded_cutscene):
	if not loaded_cutscene.is_connected("cutscene_ended", self, "_on_end_cutscene_finished"):
		loaded_cutscene.connect("cutscene_ended", self, "_on_end_cutscene_finished", [], CONNECT_ONESHOT)
	#print("JetpackGame.gd | CUTSCENE LOADED | END SIGNAL CONNECTED")


func _on_end_cutscene_finished():
	if not ScreenManager.is_connected("transition_ended", self, "level_completed"):
		ScreenManager.connect("transition_ended", self, "level_completed", [], CONNECT_ONESHOT)
	#print("JetpackGame.gd | CUTSCENE ENDED | TRANSITION SIGNAL CONNECTED")
	player.gravity_force = 0
	player.jetpack_force = 0


func level_completed():
	if game_mode == "story":
		Global.update_story_next_upgrade(next_upgrade)
	hud_animator.play("fade_out")
	if game_mode == "story":
		level_complete_screen.open(level_num, level_title)
	elif game_mode == "speedrun":
		level_complete_screen.open(-1, level_num)


func player_reset_y():
	hud_animator.play_backwards("fade_out")
	player.reset_y()
	
	var boost_timer = get_node("AutoBoost")
	Input.action_press("boost")
	boost_timer.start()
	yield(boost_timer,"timeout")
	Input.action_release("boost")
	
func set_laps(lap_count):
	time_laps_label.set_text("Laps: %s"%[lap_count])

func is_last_stage():
	if current_level == level_loader.get_max_levels()-1:
		return true
	else:
		return false
