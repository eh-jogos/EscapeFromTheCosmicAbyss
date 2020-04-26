extends Button

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var track
var arrows_highlight

func _ready():
	set_process_input(false)
	
	if not self.is_connected("mouse_entered",self,"_on_mouse_enter"):
		self.connect("mouse_entered",self,"_on_mouse_enter")
	
	if not self.is_connected("focus_entered",self,"_on_focus_enter"):
		self.connect("focus_entered",self,"_on_focus_enter")
	
	if not self.is_connected("focus_exited",self,"_on_focus_exit"):
		self.connect("focus_exited",self,"_on_focus_exit")
	
	arrows_highlight = get_node("ArrowsIndicator")
	
	track = Global.savedata["options"]["track"]
	self.set_text("BGM: "+track)


func _input(event):
	if event.is_action_pressed("ui_right"):
		change_bgm_track(true)
	elif event.is_action_pressed("ui_left"):
		change_bgm_track(false)


func change_bgm_track(direction):
	var go_down = direction
	var track_values = SoundManager.track_list.keys()
	#print(track_values)
	
	var current_index = track_values.find(track)
	var next_index
	
	SoundManager.play_sfx("ui_change", true)
	
	if current_index == -1:
		print("ERROR | TRACK NOT FOUND")
	else:
		#print("Track Values Size: %s | Current Index: %s | Track Name: %s"%[track_values.size(),current_index, track_values[current_index]])
		if go_down:
			if current_index < track_values.size()-1:
				next_index = current_index + 1
			else:
				next_index = 0
		else:
			if current_index > 0:
				next_index = current_index - 1
			else:
				next_index = track_values.size()-1
		
		track = track_values[next_index]
		self.set_text("BGM: "+track)
		#print("Next Index: %s | Track Value: %s"%[next_index, track])
		
		SoundManager.preview_bgm(track)
		Global.update_option_track(track)

func _on_mouse_enter():
	self.grab_focus()

func _on_focus_enter():
	#print("FOCUS GRABBED")
	set_process_input(true)
	SoundManager.preview_bgm_play()
	arrows_highlight.show_highlight()

func _on_focus_exit():
	#print("FOCUS LOST")
	set_process_input(false)
	arrows_highlight.stop_highlight()
	SoundManager.play_sfx("ui_select")

func _on_ArrowsIndicator_left_pressed():
	change_bgm_track(false)


func _on_ArrowsIndicator_right_pressed():
	change_bgm_track(true)

