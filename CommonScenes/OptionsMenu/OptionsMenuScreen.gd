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


func _on_Restart_pressed():
	get_tree().change_scene("res://CommonScenes/HybridStrategies/SplashScreen.tscn")
	ScreenManager.reset_above_below()
