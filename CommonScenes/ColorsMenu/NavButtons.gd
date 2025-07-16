extends HBoxContainer

func _ready():
	Global.connect("page_updated", Callable(self, "_on_Global_page_updated"))


func _on_Global_page_updated(first_button: Button, last_button: Button) -> void:
	var exit_button = $Exit
	for child in get_children():
		var button: Button = child as Button
		button.focus_neighbor_bottom = button.get_path_to(first_button)
		button.focus_neighbor_top = button.get_path_to(last_button)
	
	first_button.focus_neighbor_top = first_button.get_path_to(exit_button)
	last_button.focus_neighbor_bottom = last_button.get_path_to(exit_button)
