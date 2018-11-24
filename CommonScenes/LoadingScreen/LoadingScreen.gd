extends CanvasLayer

# I learned this in this link 
# http://docs.godotengine.org/en/stable/learning/features/misc/background_loading.html

var animation
var progress_bar

var loader
var animation_loaded = false
var time_max = 100 #msec

var scene_above

var scene_below
var previous_focus

func _ready():
	animation = self.get_node("AnimationPlayer")
	progress_bar = self.get_node("ColorFrame/TextureProgress")
	pass

func load_above(path, focus_path, origin_scene):
	if scene_above != null:
		print("ERROR | Scene Above is not null")
		return
	
	scene_below = origin_scene
	previous_focus = focus_path
	
	scene_above = load(path).instance()
	
	get_tree().get_root().call_deferred("add_child",scene_above)
	#scene_above.set_pos(scene_below.get_global_pos())

func clear_above():
	if scene_above == null:
		print("ERROR | Scene Above is null")
		return
	
	get_tree().get_root().remove_child(scene_above)
	scene_above = null
	
	if previous_focus != null and previous_focus.has_method("grab_focus"):
		if scene_below == previous_focus:
			previous_focus.grab_focus()
		else:
			scene_below.get_node(previous_focus).grab_focus()
	else:
		print("Scene Below: %s | Previous Focus: %s | grab_focus(): %s"%[
				scene_below.get_name(),
				previous_focus.get_name(),
				previous_focus.has_method("grab_focus"),
		])
		pass
	
	previous_focus = null
	scene_below = null

func reset_above_below():
	if scene_above == null:
		print("ERROR | Scene Above is null")
		return
	
	get_tree().get_root().remove_child(scene_above)
	scene_above = null
	scene_below = null
	previous_focus = null

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
	progress_bar.set_value(0)
	animation_loaded = false

func animation_ready():
	animation_loaded = true