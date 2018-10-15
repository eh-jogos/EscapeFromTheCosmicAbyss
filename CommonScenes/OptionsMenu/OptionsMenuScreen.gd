extends CanvasLayer

var fullscreen_btn
var animator

func _ready():
	fullscreen_btn = get_node("MenuContainer/FullscreenOption")
	fullscreen_btn.grab_focus()
	
	animator = self.get_node("AnimationPlayer")
	animator.play_backwards("close")
	pass


func _on_options_exit_pressed():
	Global.save()
	SoundManager.stop_preview_bgm()
	SoundManager.change_bgm_track()
	
	animator.play("close")
	
	yield(animator,"finished")
	
	ScreenManager.clear_above()
