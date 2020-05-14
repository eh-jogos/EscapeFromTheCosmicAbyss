extends CanvasLayer

signal cutscene_ended

var scenes
var current_scene

var current_animator
var next_button

# array of animations, 0 must always be "00_base" and 1 must always be "01_fade"
# and the fade in step should only animate the opacity of the parent node so it can be used both for fade ins or outs
var animator_steps
var current_step

func _ready():
	get_tree().set_pause(true)
	set_process_input(true)
	
	next_button = get_node("Buttons/Next")
	next_button.grab_focus()
	next_button.release_focus()
	
	scenes = get_node("Scenes").get_children()
	current_scene = 0
	setup_next_scene_animator()


func _unhandled_input(event):
	if event.is_action("ui_cancel") or event.is_action("ui_accept"):
		get_viewport().set_input_as_handled()
	
	if event.is_action_released("ui_cancel") and not event.is_echo():
		_on_Skip_pressed()
	elif event.is_action_released("ui_accept") and not event.is_echo():
		_on_Next_pressed()


func setup_next_scene_animator():
	#print("Cutscenes.gd | Setup Next scene animator: %s"%current_scene)
	current_animator = scenes[current_scene].get_node("AnimationPlayer")
	animator_steps = current_animator.get_animation_list()
	current_step = 1
	_play_current_animation()
	#add 1 because the fade anmation automatically transitions to the next one
	current_step += 1


func _on_Next_pressed():
	#print("Cutscenes.gd | NEXT PRESSED")
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
	_play_current_animation()


func go_to_next_scene():
	if has_more_scenes():
		fade_out_current_scene()
		current_scene += 1
		setup_next_scene_animator()
	else:
		close()

func fade_out_current_scene():
	var fade_out_scene = scenes[current_scene]
	current_animator.play_backwards(animator_steps[1])
	yield(current_animator, "animation_finished")
	fade_out_scene.hide()

func has_more_scenes():
	return current_scene + 1 < scenes.size()


func close():
	get_tree().set_pause(false)
	emit_signal("cutscene_ended")
	if get_tree().get_current_scene() == self:
		for child in get_children():
			child.hide()
	else:
		ScreenManager.black_transition_from_above()


func _on_Skip_pressed():
	print_debug("Cutscenes.gd | SKIP PRESSED")
	close()


func _play_current_animation():
#	current_animator.assigned_animation = animator_steps[current_step]
#	current_animator.seek(0, true)
	current_animator.play(animator_steps[current_step])
