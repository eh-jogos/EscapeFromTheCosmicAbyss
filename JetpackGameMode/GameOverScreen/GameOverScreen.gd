extends Node2D

var replay_btn
var current_scene
var score
var label_score
var highscore
var label_highscore
var congratulations


func _ready():
	replay_btn = self.get_node("Replay")
	label_score = self.get_node("Score")
	label_highscore = self.get_node("Highscore")
	congratulations = self.get_node("HighscoreText")
	
	current_scene = get_parent().get_parent()
	pass

func open():
	self.show()
	get_tree().set_pause(true)
	replay_btn.grab_focus()
	
	score = current_scene.get_score()
	print_score(score, label_score)
	
	highscore = Global.savedata["highscore"]
	print_score(highscore, label_highscore)
	
	if score > highscore:
		congratulations.show()
		Global.update_highscore(score)

func _on_replay_pressed():
	if current_scene != null:
		resume_game()
#		ScreenManager.load_screen("res://JetpackGameMode/JetpackGame.tscn", self)
		get_tree().change_scene("res://JetpackGameMode/JetpackGame.tscn")
		
func _on_quit_pressed():
	get_tree().quit()


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

