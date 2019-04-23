extends CanvasLayer

signal cutscene_ended

var scenes
var current_scene

var buttons

var current_animator
var animator_steps #array of animations, 0 mus always be "00_base" and 1 must always be "01_fade_in"
var current_step

func _ready():
	get_tree().set_pause(true)
	set_process_input(true)
	
	scenes = get_node("Scenes").get_children()
	buttons = get_node("Buttons").get_children()
	current_scene = 0
	setup_next_scene_animator()
	


func _input(event):
	if event.is_action_pressed("ui_accept"):
		_on_Next_pressed()
	elif event.is_action_pressed("ui_cancel"):
		_on_Skip_pressed()


func setup_next_scene_animator():
	print("Cutscenes.gd | Setup Next scene animator: %s"%current_scene)
	current_animator = scenes[current_scene].get_node("AnimationPlayer")
	animator_steps = current_animator.get_animation_list()
	current_step = 1
	current_animator.play(animator_steps[current_step])


func _on_Next_pressed():
	print("Cutscenes.gd | NEXT PRESSED")
	if current_animator.is_playing():
		skip_current_animation_step()
	elif scene_has_more_steps():
		go_to_next_animation_step()
	else:
		go_to_next_scene()


func skip_current_animation_step():
	var length = current_animator.get_current_animation_length()
	current_animator.seek(length, true)


func scene_has_more_steps():
	return animator_steps.size() > 2 and current_step + 1 < animator_steps.size()


func go_to_next_animation_step():
	current_step += 1
	current_animator.play(animator_steps[current_step])


func go_to_next_scene():
	current_scene += 1
	if has_more_scenes():
		current_animator.play_backwards(animator_steps[1])
		setup_next_scene_animator()
	else:
		close()


func has_more_scenes():
	return current_scene < scenes.size()


func close():
	get_tree().set_pause(false)
	emit_signal("cutscene_ended")
	ScreenManager.black_transition_from_above()


func _on_Skip_pressed():
	print("Cutscenes.gd | SKIP PRESSED")
	close()