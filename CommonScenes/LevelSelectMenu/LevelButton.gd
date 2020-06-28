extends TextureButton

export(int) var level_num = 0
export(String) var level_name = "title"
export(NodePath) var number_label
export(NodePath) var title_label
export(NodePath) var animator_path
export(NodePath) var menu_animator_path
export(NodePath) var highscore_label_path = "../..//Highscore"

var level_number
var level_title
var particle_fx
var animator
var menu_animator
var highscore_label
var game_settings

func _ready():
	self.connect("mouse_entered",self,"_on_mouse_enter")
	if not self.is_connected("focus_entered", self, "_on_focus_enter"):
		self.connect("focus_entered", self, "_on_focus_enter")
	
	level_number = get_node(number_label)
	level_title = get_node(title_label)
	animator = get_node(animator_path)
	menu_animator = get_node(menu_animator_path)
	highscore_label = get_node(highscore_label_path)
	particle_fx = get_node("Particles2D")
	game_settings = Global.get_game_mode()
	
	if Global.achievements_handler.has_highscore_on.has(str(level_num)):
		if Global.achievements_handler.has_highscore_on[str(level_num)]:
			$Star.show()
		else:
			$Star.hide()


func _on_mouse_enter():
	self.grab_focus()

func _on_focus_enter():
	if not self.is_connected("focus_exited", self, "_on_focus_exit"):
		self.connect("focus_exited", self, "_on_focus_exit")


func _on_focus_exit():
	SoundManager.play_sfx("Select")


func _on_LevelButton_pressed():
	if self.is_connected("focus_exited", self, "_on_focus_exit"):
		self.disconnect("focus_exited", self, "_on_focus_exit")
	
	SoundManager.play_sfx("Confirm")
	
	print("%s | Level Num: %s"%[self.get_name(),level_num])
	Global.is_retry = false
	if game_settings["sub-mode"] == "select level":
		set_level_and_close()
	else:
		set_level_and_reload()

func set_level_and_close():
	Global.set_current_story_level(level_num)
	menu_animator.play("close")
	if SoundManager.is_faded_out:
		SoundManager.fade_in_start()
	yield(menu_animator, "animation_finished")
	
	var game = get_tree().get_root().get_node("JetpackGame")
	game.game_start()
	
	ScreenManager.reset_above_below()

func set_level_and_reload():
	var game_path = "res://JetpackGameMode/JetpackGame.tscn"
	
	Global.set_current_story_level(level_num)
	ScreenManager.load_screen(game_path)
	if SoundManager.is_faded_out:
		SoundManager.fade_in_start()
	menu_animator.play("close")
	
	yield(menu_animator, "animation_finished")
	ScreenManager.reset_above_below()

func _on_LevelButton_focus_enter():
	var level_num_str = "Stage %02d"%[level_num]
	var highscore = Global.savedata["story"]["highscore"][level_num]
	var highscore_str = "Highscore: %03d"%[highscore]
	
	level_number.set_text(level_num_str)
	level_title.set_text(level_name)
	highscore_label.set_text(highscore_str)
	pass # replace with function body


func toggle_particle(on_off):
	particle_fx.set_emitting(on_off)

func transition_animation(anim):
	self.grab_focus()
	animator.play(anim)
