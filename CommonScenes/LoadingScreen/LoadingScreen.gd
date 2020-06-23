extends CanvasLayer

signal mid_transition_reached
signal transition_ended
signal loading_started

signal scene_above_loaded(scene_node)
signal scene_above_cleared(scene_below)
signal background_loading_finished(results_dict)

# I learned this in this link 
# http://docs.godotengine.org/en/stable/learning/features/misc/background_loading.html

var animation: AnimationPlayer
var progress_bar

var loader
var animation_loaded = false
var load_without_animation = false
var time_max = 100 #msec

var scene_above

var scenes_bellow = []
var previous_focuses = []

func _ready():
	animation = self.get_node("AnimationPlayer")
	progress_bar = self.get_node("ColorRect/TextureProgress")  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	reset()

func reset():
	progress_bar.set_value(0)
	animation_loaded = false
	load_without_animation = false

func load_above(path, origin_focus_path, origin_scene, path_is_node = false):
	scenes_bellow.append(origin_scene)
	previous_focuses.append(origin_focus_path)
	
	if path_is_node:
		scene_above = path.instance()
	else:
		scene_above = load(path).instance()
	
	emit_signal("scene_above_loaded", scene_above)
	
	get_tree().get_root().call_deferred("add_child",scene_above)
	#scene_above.set_position(scenes_bellow.get_global_position())  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	
	print("Scenes Below: %s | Previous Focuses%s"%[
			_get_scenes_below_names(),
			previous_focuses
	])


func background_loading(path):
	var bg_loader = ResourceLoader.load_interactive(path)
	var poll_results = bg_loader.poll()
	while not poll_results == ERR_FILE_EOF:
		if poll_results == OK:
			update_progress(bg_loader)
		else: # error during loading
			print(poll_results)
			#show_error()
			loader = null
			emit_signal("background_loading_finished", {error = poll_results, scene = null})
			return 
		
		poll_results = bg_loader.poll()
	
	emit_signal("background_loading_finished", {error = OK, scene = bg_loader.get_resource()})
	return


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
	
	emit_signal("scene_above_cleared", scene_below)
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
	yield(animation, "animation_finished")
	loader = ResourceLoader.load_interactive(path)
	if loader == null:
#		show_error()
		return
	
	set_process(true)


func load_screen_invisible(path):
	load_without_animation = true
	var loading_thread = Thread.new()
	var thread_status = loading_thread.start(self, "background_loading", path)
	if thread_status == OK:
		var results_dict: Dictionary = yield(self, "background_loading_finished")
		if results_dict.error == OK: 
			set_new_scene(results_dict.scene)
		else:
			push_error("Error while loading %s | Error: %s"%[path, results_dict.error])
			assert(false)
	else:
		push_error("Error while starting thread for %s | Error: %s"%[path, thread_status])
		assert(false)

	if loading_thread.is_active():
		loading_thread.wait_to_finish()
	set_process(true)


func reveal_invisible_loading_screen():
	animation.play("fade_in")


func _process(_delta):
	if loader == null:
		set_process(false)
		return
	
	var _t = OS.get_ticks_msec()
	if (animation_loaded or load_without_animation):
		# poll your loader
		var err = loader.poll()
		
		if err == ERR_FILE_EOF: # load finished
			var resource = loader.get_resource()
			loader = null
			set_new_scene(resource)
		elif err == OK:
			update_progress(loader)
		else: # error during loading
			print(err)
			#show_error()
			loader = null

func update_progress(current_loader: ResourceInteractiveLoader):
	var stages_current: = current_loader.get_stage()
	var stages_total: = current_loader.get_stage_count()
	var progress = (float(stages_current) / stages_total)*100
#	print("Loading is at: %s | Stage: %s | Total: %s"%[progress, stages_current, stages_total])
	# update your progress bar?
	progress_bar.set_value(progress)


func set_new_scene(scene_resource):
	progress_bar.set_value(100)
	if not animation_loaded:
		animation.play("black_transition")
		yield(animation, "animation_finished")
	
# warning-ignore:return_value_discarded
	get_tree().change_scene_to(scene_resource)
	
	if animation_loaded:
		animation.play("fade_out")
	else:
		animation.play("black_transition_out")
	yield(animation, "animation_finished")
	reset()

func animation_ready():
	animation_loaded = true
	emit_signal("loading_started")

func black_transition(path, focus_path, origin_scene, path_is_node = false):
	if animation.is_playing():
		return 
	animation.play("black_transition")
	yield(animation, "animation_finished")
	load_above(path, focus_path, origin_scene, path_is_node)
	emit_signal("mid_transition_reached")
	animation.play("black_transition_out")
	yield(animation, "animation_finished")
	reset()
	emit_signal("transition_ended")

func black_transition_replace(path):
	animation.play("black_transition")
	yield(animation, "animation_finished")
	emit_signal("mid_transition_reached")
# warning-ignore:return_value_discarded
	get_tree().change_scene(path)
	animation.play("black_transition_out")
	yield(animation, "animation_finished")
	reset()
	emit_signal("transition_ended")

func black_transition_from_above():
	animation.play("black_transition")
	yield(animation, "animation_finished")
	clear_above()
	emit_signal("mid_transition_reached")
	animation.play("black_transition_out")
	yield(animation, "animation_finished")
	reset()
	emit_signal("transition_ended")


func _get_scenes_below_names():
	var names_array = []
	if scenes_bellow.size() > 0:
		for scene in scenes_bellow:
			names_array.append(scene.get_name())
	
	return names_array

