extends Node2D

# class member variables go here, for example:
var game
@export var level_num: NodePath
@export var level_title: NodePath
@export var tip_selector: NodePath

var tips_countdown = [0,3,7,2,9]
var next_countdown = 0
var countdown

var is_showing_tip: = false

@export_category("Debug Properties")
@export_range(0.0, 4.0) var _debug_tip_number := 0

@onready var _level_num = get_node(level_num)
@onready var _level_title = get_node(level_title)
@onready var _tip_selector := get_node(tip_selector) as AnimationPlayer

# TODO Fix Node errors
func _ready():
	game = get_parent().get_parent()
	
	_tip_selector.assigned_animation = "TipScreen_0"
	_tip_selector.seek(0, true)
	set_process_input(false)
	
	if get_tree().current_scene == self:
		_tip_selector.play("TipScreen_%s"%[_debug_tip_number])


func play(num, title):
	get_tree().set_pause(true)
	show()
	#SoundManager.stop_bgm()
	game.initialize_game_stats()
	_level_num.set_text(str(num))
	_level_title.set_text(title)
	load_next_tip()


func show_tip():
	get_tree().set_pause(true)
	show()
	game.hud_animator.play("fade_out")
	load_next_tip()

func _input(event):
	if event.is_action_pressed("boost"):
		game.hud_animator.play_backwards("fade_out")
		game.player_reset_y()
		get_tree().set_pause(false)
		hide()
		is_showing_tip = false
		#Process is being set to true by TipSelector when needed
		set_process_input(false)
		
		if not SoundManager.bgm_stream.is_playing():
			SoundManager.play_bgm("2")


func beat_countdown():
	countdown -= 1
	if countdown == 0:
		show_tip()


func load_next_tip():
	is_showing_tip = true
	_tip_selector.play("TipScreen_%s"%[next_countdown])
	next_countdown += 1
	
	if next_countdown >= tips_countdown.size():
		#print("END OF TIPS | Reseting tip settings")
		next_countdown = 0
		countdown = 0
	else:
		countdown = tips_countdown[next_countdown]
