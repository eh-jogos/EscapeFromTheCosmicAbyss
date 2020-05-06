extends Node2D

var animator

func _ready():
	animator = get_node("AnimationPlayer")
	
	var menu_block = get_node("Menu/MenuRoot/MenusBlock")
	menu_block.current_menu = menu_block.current_menu


func _on_Exit_pressed():
	close()


func _on_Reset_pressed():
	Global.read()
	Global.emit_signal("reset_color_pickers")
	get_tree().call_group("interactive_color", "colors_changed")


func _on_ResetDefaults_pressed():
	Global.reset_colors()
	Global.emit_signal("reset_color_pickers")
	get_tree().call_group("interactive_color", "colors_changed")


func close():
	Global.save()
	if get_tree().get_current_scene() == self:
		var menu_root = get_node("Menu/MenuRoot")
		menu_root.hide()
		hide()
	else:
		ScreenManager.black_transition_from_above()


func _on_MenuWaves_activated():
	if animator == null:
		return
	
	animator.play("base")


func _on_MenuTentacles_activated():
	if animator == null:
		return
	
	animator.play("tentacles")


func _on_MenuLaserEye_activated():
	if animator == null:
		return
	
	animator.play("laser_eye")


func _on_MenuBgBoss_activated():
	if animator == null:
		return
	
	animator.play("bg_boss")


func _on_MenuMidBoss_activated():
	if animator == null:
		return
	
	animator.play("mid_boss")


func _on_MenuFinalBoss_activated():
	if animator == null:
		return
	
	animator.play("final_boss_entrance")


func _on_MenuFinalBoss1_activated():
	if animator == null:
		return
	
	animator.play("final_boss_laser_loop")
