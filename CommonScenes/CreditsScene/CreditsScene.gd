extends ColorRect
# Write your doc striing for this file here

### Member Variables and Dependencies -----
# signals 
# enums
# constants
const SPEED_MODIFIER = 10
# public variables - order: export > normal var > onready 
# private variables - order: export > normal var > onready 
onready var _animator: AnimationPlayer = $AnimationPlayer
### ---------------------------------------


### Built in Engine Methods ---------------
func _ready():
	if not Global.was_credits_called_from_extras:
		ScreenManager.reset_above_below()
	set_process(false)
	set_process_unhandled_input(false)
	set_process_input(true)
	grab_focus()
	SoundManager.play_bgm("electro")
	_animator.play("credits")


func _input(_event):
	get_viewport().set_input_as_handled()


func _unhandled_input(event):
	if event.is_action_pressed("ui_accept"):
		if _animator.is_playing():
			_animator.stop(false)
		else:
			_animator.play()
	
	if event.is_action_pressed("ui_cancel"):
		_exit_credits()


func _process(_delta):
	if Input.is_action_pressed("ui_up"):
		_animator.playback_speed = -SPEED_MODIFIER
	elif Input.is_action_pressed("ui_down"):
		if not _animator.is_playing() and _animator.current_animation_position == 0:
			_animator.play()
		
		_animator.playback_speed = SPEED_MODIFIER
	else:
		if not _animator.is_playing() and _animator.current_animation_position == 0:
			_animator.play()
		
		_animator.playback_speed = 1

### ---------------------------------------


### Public Methods ------------------------
### ---------------------------------------


### Private Methods -----------------------
func _activate_navigation() -> void:
	set_process(true)
	set_process_unhandled_input(true)
	set_process_input(false)


func _fade_out_music() -> void:
	SoundManager.fade_out_credits_bgm()


func _exit_credits() -> void:
	SoundManager.stop_bgm()
	if Global.was_credits_called_from_extras:
		Global.was_credits_called_from_extras = false
		ScreenManager.black_transition_from_above()
	else:
		ScreenManager.load_screen("res://CommonScenes/MainMenu/MainMenuScreen.tscn")


func _on_GodotTeamLink_pressed():
	OS.shell_open("https://godotengine.org/contact")


func _on_GodotSteam_pressed():
	OS.shell_open("https://gramps.github.io/GodotSteam/index.html")


func _on_GDQuest_pressed():
	OS.shell_open("https://www.gdquest.com/")


func _on_GodorReddit_pressed():
	OS.shell_open("https://www.reddit.com/r/godot/")


func _on_OpenGameArt_pressed():
	OS.shell_open("https://opengameart.org/content/free-keyboard-and-controllers-prompts-pack")


func _on_SamOzTwitter_pressed():
	OS.shell_open("https://twitter.com/SamOz_official")


func _on_MadrugaTwitter_pressed():
	OS.shell_open("https://twitter.com/artbycoltz")

### ---------------------------------------
