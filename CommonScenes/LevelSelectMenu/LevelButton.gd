extends TextureButton

export(int) var level_num = 0
export(String) var level_name = "title"
export(NodePath) var number_label
export(NodePath) var title_label
export(NodePath) var animator_path

var level_number
var level_title
var particle_fx
var animator

func _ready():
	self.connect("mouse_enter",self,"_on_mouse_enter")
	level_number = get_node(number_label)
	level_title = get_node(title_label)
	animator = get_node(animator_path)
	particle_fx = get_node("Particles2D")

func _on_mouse_enter():
	self.grab_focus()

func _on_LevelButton_pressed():
	var game_path = "res://JetpackGameMode/JetpackGame.tscn"
	Global.set_current_story_level(level_num, level_name)
	ScreenManager.reset_above_below()
	ScreenManager.load_screen(game_path)


func _on_LevelButton_focus_enter():
	var level_num_str
	if level_num >= 10:
		level_num_str = "Level %s"%[level_num]
	elif level_num > 0:
		level_num_str = "Level 0%s"%[level_num]
	else:
		level_num_str = "Tutorial"
	
	level_number.set_text(level_num_str)
	level_title.set_text(level_name)
	pass # replace with function body


func toggle_particle(on_off):
	particle_fx.set_emitting(on_off)

func transition_animation(anim):
	self.grab_focus()
	animator.play(anim)