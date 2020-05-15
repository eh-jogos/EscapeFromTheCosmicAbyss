extends Button

# class member variables go here, for example:
var upgrade_brain
var stat_bar
var stat_value

onready var plus = get_node("Plus")
onready var minus = get_node("Minus")

##################
# Custom Methods #
##################
func get_stat_value():
	return upgrade_brain.cooldown

func set_stat_value(value):
	upgrade_brain.cooldown = value


func init_bar(bar_stat, should_be_pending):
	var max_stats = stat_bar.get_child_count()
	
	handle_button_states(bar_stat, max_stats)
	
	if bar_stat <= max_stats:
		for stat in range(0,max_stats):
			var slot = stat_bar.get_child(stat)
			if stat < bar_stat:
				if should_be_pending:
					slot.pending_upgrade()
				else:
					slot.apply_upgrade()
			else:
				slot.base_slot()
	else:
		for stat in range(0,max_stats):
			var slot = stat_bar.get_child(stat)
			slot.apply_upgrade()
		
		print("ERROR | Saved Stat is bigger than Max Stat")
		print("%s | Saved Stat: %s | Max Stat %s"%[get_name(), bar_stat, max_stats])


func increase_bar():
	if upgrade_brain.upgrade_points > 0:
		var max_stats = stat_bar.get_child_count()
		stat_value = get_stat_value()
		
		if stat_value+1 <= max_stats:
			SoundManager.play_sfx("Change")
			upgrade_brain.upgrade_points -= 1
			upgrade_brain.up_label.set_text(str(upgrade_brain.upgrade_points))
			
			var slot = stat_bar.get_child(stat_value)
			slot.pending_upgrade()
			
			stat_value += 1
			set_stat_value(stat_value)
			handle_button_states(stat_value, max_stats)
			print("Node Name: %s | Stat: %s"%[stat_bar.get_parent().get_name(), stat_value])
		else:
			handle_button_states(stat_value, max_stats)
			print("ERROR | Saved Stat is Maxed Out")
			print("%s | Saved Stat: %s | Max Stat %s"%[stat_bar.get_parent().get_name(), stat_value, max_stats])

func decrease_bar():
	var max_stats = stat_bar.get_child_count()
	stat_value = get_stat_value()
	
	if stat_value-1 >= 0:
		SoundManager.play_sfx("Change")
		upgrade_brain.upgrade_points += 1
		upgrade_brain.up_label.set_text(str(upgrade_brain.upgrade_points))
		
		stat_value -= 1
		set_stat_value(stat_value)
		handle_button_states(stat_value, max_stats)
		print("Node Name: %s | Stat: %s"%[stat_bar.get_parent().get_name(), stat_value])
		
		var slot = stat_bar.get_child(stat_value)
		slot.base_slot()
	else:
		handle_button_states(stat_value, max_stats)
		print("ERROR | Saved Stat is Maxed Out")
		print("%s | Saved Stat: %s | Max Stat %s"%[stat_bar.get_parent().get_name(), stat_value, max_stats])


func validate_stat_value():
	stat_value = get_stat_value()
	var max_value = stat_bar.get_child_count()
	if stat_value > max_value:
		set_stat_value(max_value)
	elif stat_value < 0:
		set_stat_value(0)


func handle_button_states(value, max_stats):
	if value == max_stats:
		plus.set_disabled(true)
	elif value == 0:
		minus.set_disabled(true)
	else:
		plus.set_disabled(false)
		minus.set_disabled(false)


###########################
# Engine Standard Methods #
###########################

func _ready():
	set_process_input(false)
	
	upgrade_brain = self.get_parent().get_parent()
	stat_bar = self.get_node("UpgradeBar")
	
	if not self.is_connected("mouse_entered",self,"_on_mouse_enter"):
		self.connect("mouse_entered",self,"_on_mouse_enter")
	
	if not self.is_connected("focus_entered",self,"_on_focus_enter"):
		self.connect("focus_entered",self,"_on_focus_enter")
	
	if not self.is_connected("focus_exited",self,"_on_focus_exit"):
		self.connect("focus_exited",self,"_on_focus_exit")


func _input(event):
	if event.is_action_pressed("ui_right"):
		var button = get_node("Plus")
		button.simulate_press()
		_on_Plus_pressed()
	elif event.is_action_pressed("ui_left"):
		var button = get_node("Minus")
		button.simulate_press()
		_on_Minus_pressed()

func _on_Plus_pressed():
	self.increase_bar()

func _on_Minus_pressed():
	self.decrease_bar()

func _on_mouse_enter():
	self.grab_focus()

func _on_focus_enter():
	#print("FOCUS GRABBED")
	set_process_input(true)
	
	plus.simulate_hover()
	minus.simulate_hover()
	
	self.get_node("AnimationPlayer").play("blink")
	self.get_node("ArrowsIndicator").show_highlight()

func _on_focus_exit():
	#print("FOCUS LOST")
	set_process_input(false)
	
	plus.reset()
	minus.reset()
	
	SoundManager.play_sfx("Select")
	self.get_node("AnimationPlayer").play("base")
	self.get_node("ArrowsIndicator").stop_highlight()

