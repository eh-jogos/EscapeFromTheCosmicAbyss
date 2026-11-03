extends MarginContainer

signal activated

func activate():
	var list = get_node("List/Buttons")
	for button_line in list.get_children():
		button_line.enable_buttons()
	
	var first_line = list.get_child(0)
	var last_line = list.get_child(list.get_child_count() - 1)
	
	var first_button = first_line.get_child(0)
	var last_button = last_line.get_child(0)
	
	first_button.grab_focus()
	
	Global.page_updated.emit(first_button, last_button)
	activated.emit()


func deactivate():
	var list = get_node("List/Buttons")
	for button_line in list.get_children():
		button_line.disable_buttons()
