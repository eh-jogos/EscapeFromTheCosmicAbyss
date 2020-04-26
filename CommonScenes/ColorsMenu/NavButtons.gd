extends HBoxContainer

func _ready():
	Global.connect("page_updated", self, "_on_Global_page_updated")


func _on_Global_page_updated(first_button, last_button):
	for child in get_children():
		child.set_focus_neighbour(MARGIN_BOTTOM, first_button.get_path())
		child.set_focus_neighbour(MARGIN_TOP, last_button.get_path())
