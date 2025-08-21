extends CanvasLayer

signal mid_transition_reached
signal transition_ended

signal scene_above_loaded(scene_node)
signal scene_above_cleared(scene_below)
signal background_loading_finished(results_dict)

enum LoadingType {
	NONE,
	BACKRGROUND,
	LOADING_SCREEN
}

var animation_loaded = false
var load_without_animation = false

var scene_above

var scenes_bellow = []
var previous_focuses = []

var loading_path = ""

var _current_loading_path := ""
var _current_type := LoadingType.NONE

@onready var _animation := $AnimationPlayer as AnimationPlayer
@onready var _progress_bar := $ColorRect/TextureProgressBar as TextureProgressBar


func _ready() -> void:
	set_process(false)
	
	if get_tree().current_scene == self:
		_animation.play("fade_in")


func _process(_delta):
	if _current_type == LoadingType.NONE:
		set_process(false)
		return
	
	var progress := []
	var err := ResourceLoader.load_threaded_get_status(_current_loading_path, progress)
	if err == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		_progress_bar.set_value(progress[0])
	elif err == ResourceLoader.THREAD_LOAD_LOADED:
		var scene: PackedScene = ResourceLoader.load_threaded_get(_current_loading_path)
		if _current_type == LoadingType.LOADING_SCREEN:
			set_new_scene(scene)
		elif _current_type == LoadingType.BACKRGROUND:
			background_loading_finished.emit({error = err, scene = scene})
	else:
		push_error("Failed loading scene | Error: %s | Path: %s"%[
			err,
			_current_loading_path
		])
		if _current_type == LoadingType.BACKRGROUND:
			background_loading_finished.emit({error = err, scene = null})


func reset():
	_animation.play("RESET")
	_current_type = LoadingType.NONE
	load_without_animation = false


func load_above(path, origin_focus_path, origin_scene, path_is_node = false):
	if origin_scene in scenes_bellow:
		return
	
	var node
	if path_is_node:
		node = path
	else:
		node = load(path)
	
	scenes_bellow.append(origin_scene)
	previous_focuses.append(origin_focus_path)
	
	scene_above = node.instantiate()
	
	emit_signal("scene_above_loaded", scene_above)
	
	get_tree().get_root().call_deferred("add_child",scene_above)
	#scene_above.set_position(scenes_bellow.get_global_position())  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	
	print("Scenes Below: %s | Previous Focuses%s"%[
			_get_scenes_below_names(),
			previous_focuses
	])


func background_loading():
	var error = ResourceLoader.load_threaded_request(_current_loading_path)
	set_process(true)
	#var poll_results = bg_loader.poll()
	#while not poll_results == ERR_FILE_EOF:
		#if poll_results == OK:
			#update_progress(bg_loader)
		#else: # error during loading
			#print(poll_results)
			#loader = null
			#emit_signal("background_loading_finished", {error = poll_results, scene = null})
			#return 
		#
		#poll_results = bg_loader.poll()
	#
	#emit_signal("background_loading_finished", {error = OK, scene = bg_loader.get_resource()})


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


func load_screen(path: String):
	var err = ResourceLoader.load_threaded_request(path)
	if err != OK:
		push_error("Failed to start loading path | Error: %s | Path: %s"%[err, path])
		return
	
	_current_loading_path = path
	_current_type = LoadingType.LOADING_SCREEN
	
	_animation.play("fade_in")
	await _animation.animation_finished
	
	set_process(true)


func load_screen_invisible(path: String):
	_current_type = LoadingType.BACKRGROUND
	_current_loading_path = path
	var error = ResourceLoader.load_threaded_request(_current_loading_path)
	set_process(true)
	
	#var thread_status = _loading_thread.start(Callable(self, "background_loading").bind(path))
	#if thread_status == OK:
		#var results_dict: Dictionary = await self.background_loading_finished
		#if results_dict.error == OK: 
			#set_new_scene(results_dict.scene)
		#else:
			#push_error("Error while loading %s | Error: %s"%[path, results_dict.error])
			#assert(false)
	#else:
		#push_error("Error while starting thread for %s | Error: %s"%[path, thread_status])
		#assert(false)


func reveal_invisible_loading_screen():
	_animation.play("fade_in")


func set_new_scene(scene_resource: PackedScene):
	_progress_bar.set_value(100)
	if _current_type == LoadingType.BACKRGROUND:
		_animation.play("black_transition")
		await _animation.animation_finished
	
	# warning-ignore:return_value_discarded
	get_tree().change_scene_to_packed(scene_resource)
	
	if _animation.assigned_animation == "fade_in":
		_animation.play("fade_out")
	else:
		_animation.play("black_transition_out")
	await _animation.animation_finished
	reset()


func black_transition(path, focus_path, origin_scene, path_is_node = false):
	if loading_path == "":
		loading_path = path
	elif loading_path == path:
		return
	_animation.play("black_transition")
	await _animation.animation_finished
	load_above(path, focus_path, origin_scene, path_is_node)
	emit_signal("mid_transition_reached")
	_animation.play("black_transition_out")
	await _animation.animation_finished
	reset()
	emit_signal("transition_ended")
	loading_path = ""

func black_transition_replace(path):
	_animation.play("black_transition")
	await _animation.animation_finished
	emit_signal("mid_transition_reached")
# warning-ignore:return_value_discarded
	get_tree().change_scene_to_file(path)
	_animation.play("black_transition_out")
	await _animation.animation_finished
	reset()
	emit_signal("transition_ended")

func black_transition_from_above():
	_animation.play("black_transition")
	await _animation.animation_finished
	clear_above()
	emit_signal("mid_transition_reached")
	_animation.play("black_transition_out")
	await _animation.animation_finished
	reset()
	emit_signal("transition_ended")


func _get_scenes_below_names():
	var names_array = []
	if scenes_bellow.size() > 0:
		for scene in scenes_bellow:
			names_array.append(scene.get_name())
	
	return names_array
