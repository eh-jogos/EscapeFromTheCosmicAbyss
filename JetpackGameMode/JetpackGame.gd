extends Node2D

# Nodes this script will interact with
var overheat_bar
var overheat_bar_animator
var points_label
var upgrade_label
var upgrade_messager
var ammunition
var player
var level_loader
var object_spawner

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


var game_settings = Global.get_game_mode()
var game_mode = game_settings["game mode"]
var category = game_settings["sub-mode"]
var last_level_choice
var points = 0
var points_level = 0
var cycles = 0
var level_num
var level_title
var highscore
var initial_shield
var initial_ammo
var initial_speed
var max_speed
var laser_duration
var upgrade_points
var levels_unlocked
var cooldown
var multiplyer = 1

const STATE = {
	"Playing": 0,
	"Start": 1,
	"Pause": 2,
	"Tutorial": 3,
	"GameOver": 4
}

var current_state = STATE["Playing"]

func _ready():
	#TODO? - Change the nodes according to game mode?
	tutorial = self.get_node("AboveScreen/TutorialTipScreen")
	game_over_screen = self.get_node("AboveScreen/GameOverScreen")
	level_complete_screen = self.get_node("AboveScreen/LevelCompleteScreen")
	
	# Nodes
	countdown = self.get_node("AboveScreen/CountdownScreen")
	overheat_bar = self.get_node("HUD/TextureProgress")
	overheat_bar_animator = self.get_node("HUD/TextureProgress/AnimationPlayer")
	ammunition = self.get_node("HUD/TextureProgress/Ammunition")
	points_label = self.get_node("HUD/Points")
	upgrade_label = self.get_node("HUD/UpgradeLabel")
	upgrade_messager = self.get_node("HUD/UpgradeLabel/Messager")
	player = self.get_node("Player")
	level_loader = self.get_node("LevelLoader")
	object_spawner = self.get_node("Camera2D/ObstacleSpawner")
	
	show_pre_game()

func show_pre_game():
	if game_mode == "story":
		load_story_pregame()
	elif game_mode == "arcade" or game_mode == "speedrun":
		load_upgrade_pregame()
	else:
		print("ERROR | Invalid game mode: %s"%[game_settings])
	
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
		Global.reset_category_progress(game_settings)
		
		var path = upgrade_path
		ScreenManager.load_above(path, self, self)
	else:
		print("ERROR | Invalid sub-mode: %s"%[game_settings])

func game_start():
	initialize_game_stats()
	setup_game_mode_level()
	if current_state == STATE["Tutorial"]:
		tutorial.play(level_num, level_title)
		object_spawner.connect_tutorial_signal(tutorial)
	else:
		countdown.play(level_num, level_title)

#called from CountdownScreen, after any Pre Game has been cleared
func initialize_game_stats(): 
	if game_mode == "story":
		highscore = Global.savedata[game_mode]["highscore"]
		initial_shield = Global.savedata[game_mode]["initial shield"]
		initial_ammo = Global.savedata[game_mode]["initial ammo"]
		initial_speed = Global.savedata[game_mode]["initial speed"]
		max_speed = 4 + Global.savedata[game_mode]["max speed"]
		laser_duration = Global.savedata[game_mode]["laser duration"]
		upgrade_points = Global.savedata[game_mode]["upgrade points"]
		levels_unlocked = Global.savedata[game_mode]["levels unlocked"]
		cooldown = Global.savedata[game_mode]["cooldown"]
	
	elif game_mode == "arcade" or game_mode == "speedrun":
		highscore = Global.savedata[game_mode]["highscore"]
		initial_shield = Global.savedata[game_mode]["initial shield"]
		initial_ammo = Global.savedata[game_mode]["initial ammo"]
		initial_speed = Global.savedata[game_mode]["initial speed"]
		max_speed = 4 + Global.savedata[game_mode]["max speed"]
		laser_duration = Global.savedata[game_mode]["laser duration"]
		cooldown = Global.savedata[game_mode]["cooldown"]
	
	player.set_player_stats()
	ammunition.initialize_ammo(initial_ammo)

func setup_game_mode_level():
	if game_mode == "story":
		var num = Global.savedata["story"]["current level"]
		
		if not valid_level_choice():
			print("ERROR | LEVEL OUT OF RANGE")
			num = level_loader.get_max_levels()-1
		
		var level = load_level(num)
		
		if level.tutorial:
			set_game_state("Tutorial")
		
		if num < 10:
			level_num = "Level 0%s"%[num]
		else:
			level_num = "Level %s"%[num]
		level_title = level.title
	
	elif game_mode == "arcade":
		var num = 1
		var level = load_level(num, true)
		
		level_num = "Arcade Arena!"
		level_title = "How many laps can you survive?"
	elif game_mode == "speedrun":
		var num = 1
		var level = load_level(num, true)
		
		level_num = "Speedrun Track!"
		level_title = "Gotta Go Fast!"

func valid_level_choice(level_to_check):
	return level_to_check < level_loader.get_max_levels()

func load_level(level_choice, load_all = false):
	var level = level_loader.load_level(level_choice, load_all)
	object_spawner.set_level(level)
	return level


func set_game_state(string):
	current_state = STATE[string]

func get_game_state():
	return current_state

func get_score():
	return points

func get_overheat():
	return overheat_bar.get_value()

func set_overheat(value):
	overheat_bar.set_value(value)

func game_over():
	game_over_screen.open()
	get_tree().set_pause(true)

func _on_scored(num):
	var last_point_level = points_level
	
	points += (num*multiplyer)
	points_level = int(points/point_multiple)
	#print(points_level)
	
	if points_level > last_point_level:
		ammunition.add_ammo()
		
		print("initial_speed: %s | max_speed: %s"%[player.speed_x, max_speed])
		if player.speed_x < max_speed:
			player.speed_x += 1.0
			player.gravity += 10.0
			player.speed_y -= 20.0
			#print("speed_x: %s | gravity: %s | speed_y: %s"%[player.speed_x, player.gravity, player.speed_y])
			if not player.dashing:
				player.speed.x = player.speed_x* player.unit.x
	#			print(player.speed.x)
	
		if points_level % int(upgrade_multiple/point_multiple) == 0:
			if game_mode == "story":
				upgrade_points += 1
				upgrade_label.set_text("+ UPGRADE POINT!")
				upgrade_messager.play("text_anim")
				Global.update_story_upgrade(upgrade_points)
			elif game_mode == "arcade" or game_mode == "speedrun":
				multiplyer += 1
				upgrade_label.set_text("%s Multiplyer"%[multiplyer])
				upgrade_messager.play("text_anim")
				pass
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

func _on_level_end():
	if game_mode == "story" or game_mode == "speedrun":
		level_completed()
	elif game_mode == "arcade":
		load_level(1, true)
	else:
		printerr("ERROR | Invalid Game Mode: %s"%[game_settings])

func level_completed():
	player.gravity_force = 0
	player.jetpack_force = 0
	level_complete_screen.open(level_num)
	get_tree().set_pause(true)

func player_reset_y():
	var boost_timer = get_node("AutoBoost")
	player.reset_y()
	Input.action_press("boost")
	boost_timer.start()
	yield(boost_timer,"timeout")
	Input.action_release("boost")
	pass
