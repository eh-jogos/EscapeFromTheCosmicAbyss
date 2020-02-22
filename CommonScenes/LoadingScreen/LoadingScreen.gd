extends CanvasLayer

signal mid_transition_reached
signal transition_ended
signal loading_started

signal scene_above_loaded(scene_node)

# I learned this in this link 
# http://docs.godotengine.org/en/stable/learning/features/misc/background_loading.html

var animation
var progress_bar

var loader
var animation_loaded = false
var time_max = 100 #msec

var scene_above

var scenes_bellow = []
var previous_focuses = []

func _ready():
	animation = self.get_node("AnimationPlayer")
	progress_bar = self.get_node("ColorFrame/TextureProgress")
	reset()

func reset():
	progress_bar.set_value(0)
	animation_loaded = false

func load_above(path, focus_path, origin_scene, path_is_node = false):
	scenes_bellow.append(origin_scene)
	previous_focuses.append(focus_path)
	
	if path_is_node:
		scene_above = path.instance()
	else:
		scene_above = load(path).instance()
	
	emit_signal("scene_above_loaded", scene_above)
	
	get_tree().get_root().call_deferred("add_child",scene_above)
	#scene_above.set_pos(scenes_bellow.get_global_pos())
	
	print("Scenes Below: %s | Previous Focuses%s"%[
			_get_scenes_below_names(),
			previous_focuses
	])


func background_loading(path):
	var loader = ResourceLoader.load_interactive(path)
	while not loader.poll() == ERR_FILE_EOF:
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
		yield(get_tree(), "idle_frame")
	return loader.get_resource()


func clear_above():
	if scene_above == null:
		print("CLEAR ABOVE ERROR | Scene Above is null | Scenes Below: %s | Previous Focuses: %s"%[
				_get_scenes_below_names(),
				previous_focuses
		])
		return
	
	var previous_focus
	var scene_below
	
	get_tree().get_root().remove_child(scene_above)
	
	if previous_focuses.size() > 0:
		previous_focus = previous_focuses[previous_focuses.size()-1]
		previous_focuses.pop_back()
	
	if scenes_bellow.size() > 0:
		scene_below = scenes_bellow[scenes_bellow.size()-1]
		if scenes_bellow.size() > 1:
			scene_above = scene_below
		else:
			scene_above = null
		
		scenes_bellow.pop_back()
	
	if previous_focus != null and previous_focus.has_method("grab_focus"):
		previous_focus.grab_focus()
	
	print("Scenes Below: %s | Scene Below: %s | Previous Focus: %s "%[
			_get_scenes_below_names(),
			scene_below.get_name(),
			previous_focus,
	])
	

func reset_above_below():
	if scene_above == null:
		print("RESET ABOVE BELOW ERROR | Scene Above is null | Scenes Below: %s | Previous Focuses: %s"%[
				_get_scenes_below_names(),
				previous_focuses
		])
		return
	
	get_tree().get_root().remove_child(scene_above)
	scene_above = null
	scenes_bellow = []
	previous_focuses = []

func load_screen(path):
	animation.play("fade_in")
	yield(animation, "finished")
	loader = ResourceLoader.load_interactive(path)
	if loader == null:
#		show_error()
		return
	
	set_process(true)

func _process(delta):
	if loader == null:
		set_process(false)
		return
	
	var t = OS.get_ticks_msec()
	while OS.get_ticks_msec() < t + time_max and animation_loaded:
		# poll your loader
		var err = loader.poll()
		
		if err == ERR_FILE_EOF: # load finished
			var resource = loader.get_resource()
			loader = null
			set_new_scene(resource)
			break
		elif err == OK:
			update_progress()
		else: # error during loading
			show_error()
			loader = null
			break

func update_progress():
	var progress = (float(loader.get_stage()) / loader.get_stage_count())*100
	# update your progress bar?
	progress_bar.set_value(progress)


func set_new_scene(scene_resource):
	progress_bar.set_value(100)
	
	get_tree().change_scene_to(scene_resource)
	
	animation.play_backwards("fade_in")
	yield(animation, "finished")
	reset()

func animation_ready():
	animation_loaded = true
	emit_signal("loading_started")

func black_transition(path, focus_path, origin_scene):
	animation.play("black_transition")
	yield(animation, "finished")
	emit_signal("mid_transition_reached")
	load_above(path, focus_path, origin_scene)
	animation.play_backwards("black_transition")
	yield(animation, "finished")
	reset()
	emit_signal("transition_ended")

func black_transition_replace(path):
	animation.play("black_transition")
	yield(animation, "finished")
	emit_signal("mid_transition_reached")
	get_tree().change_scene(path)
	animation.play_backwards("black_transition")
	yield(animation, "finished")
	reset()
	emit_signal("transition_ended")

func black_transition_from_above():
	animation.play("black_transition")
	yield(animation, "finished")
	emit_signal("mid_transition_reached")
	clear_above()
	animation.play_backwards("black_transition")
	yield(animation, "finished")
	reset()
	emit_signal("transition_ended")


func _get_scenes_below_names():
	var names_array = []
	if scenes_bellow.size() > 0:
		for scene in scenes_bellow:
			names_array.append(scene.get_name())
	
	return names_array
