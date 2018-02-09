extends Node2D

# class member variables go here, for example:
var overheat_bar
var overheat_bar_animator
var points_label
var ammunition
var player

var game_over_screen
var game_over = false

var countdown
var tutorial

var points = 0


func _ready():
	game_over_screen = self.get_node("AboveScreen/GameOverScreen")
	countdown = self.get_node("AboveScreen/CountdownScreen")
	tutorial = self.get_node("AboveScreen/TutorialScreen")
	
	
	overheat_bar = self.get_node("HUD/TextureProgress")
	overheat_bar_animator = self.get_node("HUD/TextureProgress/AnimationPlayer")
	ammunition = self.get_node("HUD/TextureProgress/Ammunition")
	points_label = self.get_node("HUD/Points")
	player = self.get_node("Player")
	
	self.get_tree().set_pause(true)
	
	if Global.savedata["how to play"]:
		self.game_start()
	else:
		game_over = true
		self.tutorial_start()
	pass


func get_game_state():
	return game_over

func set_game_state(boolean):
	game_over = boolean

func get_score():
	return points

func get_overheat():
	return overheat_bar.get_value()

func set_overheat(value):
	overheat_bar.set_value(value)

func game_over():
	game_over_screen.open()
	get_tree().set_pause(true)

func _on_scored():
	points += 1
	
	if points % 5 == 0:
		ammunition.add_ammo()
		if player.speed_x < player.MAX_SPEED_X:
			player.speed_x += 1.0
			player.gravity += 10.0
			player.speed_y -= 20.0
			print("speed_x: %s | gravity: %s | speed_y: %s"%[player.speed_x, player.gravity, player.speed_y])
			if not player.dashing:
				player.speed.x = player.speed_x* player.unit.x
	#			print(player.speed.x)
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

func game_start():
	countdown.play()

func tutorial_start():
	tutorial.play()