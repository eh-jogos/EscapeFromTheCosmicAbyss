extends Button

# class member variables go here, for example:
var upgrade_brain
var stat_bar
var stat_value

##################
# Custom Methods #
##################
func get_stat_value():
	return upgrade_brain.initial_speed

func set_stat_value(value):
	upgrade_brain.initial_speed = value


func increase_bar(bar_node):
	if upgrade_brain.upgrade_points > 0:
		var max_stats = bar_node.get_child_count()
		var max_speed = upgrade_brain.max_speed
		stat_value = get_stat_value()
		
		if stat_value+1 <= max_stats and stat_value+1 <= max_speed:
			upgrade_brain.upgrade_points -= 1
			upgrade_brain.up_label.set_text(str(upgrade_brain.upgrade_points))
			
			var slot = bar_node.get_child(stat_value)
			slot.pending_upgrade()
			
			stat_value += 1
			set_stat_value(stat_value)
			print("Node Name: %s | Stat: %s"%[bar_node.get_parent().get_name(), stat_value])
		else:
			print("ERROR | Saved Stat is Maxed Out")
			print("%s | Saved Stat: %s | Max Stat %s"%[bar_node.get_parent().get_name(), stat_value, max_stats])

func decrease_bar(bar_node):
	var max_stats = bar_node.get_child_count()
	stat_value = get_stat_value()
	
	if stat_value-1 >= 0:
		upgrade_brain.upgrade_points += 1
		upgrade_brain.up_label.set_text(str(upgrade_brain.upgrade_points))
		
		stat_value -= 1
		set_stat_value(stat_value)
		print("Node Name: %s | Stat: %s"%[bar_node.get_parent().get_name(), stat_value])
		
		var slot = bar_node.get_child(stat_value)
		slot.base_slot()
	else:
		print("ERROR | Saved Stat is Maxed Out")
		print("%s | Saved Stat: %s | Max Stat %s"%[bar_node.get_parent().get_name(), stat_value, max_stats])



###########################
# Engine Standard Methods #
###########################

func _ready():
	upgrade_brain = self.get_parent().get_parent()
	stat_bar = self.get_node("UpgradeBar")
	
	if not self.is_connected("mouse_enter",self,"_on_mouse_enter"):
		self.connect("mouse_enter",self,"_on_mouse_enter")
	
	if not self.is_connected("focus_enter",self,"_on_focus_enter"):
		self.connect("focus_enter",self,"_on_focus_enter")
	
	if not self.is_connected("focus_exit",self,"_on_focus_exit"):
		self.connect("focus_exit",self,"_on_focus_exit")


func _input(event):
	if event.is_action_pressed("ui_right"):
		_on_Plus_pressed()
	elif event.is_action_pressed("ui_left"):
		_on_Minus_pressed()

func _on_Plus_pressed():
	self.increase_bar(stat_bar)

func _on_Minus_pressed():
	self.decrease_bar(stat_bar)

func _on_mouse_enter():
	self.grab_focus()

func _on_focus_enter():
	#print("FOCUS GRABBED")
	set_process_input(true)

func _on_focus_exit():
	#print("FOCUS LOST")
	set_process_input(false)
