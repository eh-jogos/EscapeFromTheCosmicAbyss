extends Node2D

# class member variables go here, for example:
var game
export(NodePath) var level_num
export(NodePath) var level_title
export(NodePath) var tip_selector

var tips_countdown = [0,3,7,2,8]
var next_countdown = 0
var countdown

func _ready():
	game = self.get_parent().get_parent()
	level_num = self.get_node(level_num)
	level_title = self.get_node(level_title)
	tip_selector = self.get_node(tip_selector)
	pass

func play(num, title):
	self.show()
	#SoundManager.stop_bgm()
	game.initialize_game_stats()
	level_num.set_text(num)
	level_title.set_text(title)
	load_next_tip()

func show_tip():
	self.get_tree().set_pause(true)
	self.show()
	load_next_tip()

func _input(event):
	if event.is_action_pressed("boost"):
		self.get_tree().set_pause(false)
		self.hide()
		self.set_process_input(false)
		
		if not SoundManager.bgm_stream.is_playing():
			SoundManager.play_bgm()

func beat_countdown():
	countdown -= 1
	if countdown == 0:
		show_tip()

func load_next_tip():
	tip_selector.play("TipScreen_%s"%[next_countdown])
	next_countdown += 1
	
	if next_countdown >= tips_countdown.size():
		#print("END OF TIPS | Reseting tip settings")
		next_countdown = 0
		countdown = 0
	else:
		countdown = tips_countdown[next_countdown]