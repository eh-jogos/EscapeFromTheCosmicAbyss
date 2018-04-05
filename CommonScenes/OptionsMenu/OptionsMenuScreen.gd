extends CanvasLayer

var fullscreen_btn

func _ready():
	fullscreen_btn = get_node("MenuContainer/FullscreenOption")
	fullscreen_btn.grab_focus()
	pass


func _on_options_exit_pressed():
	ScreenManager.clear_above()
