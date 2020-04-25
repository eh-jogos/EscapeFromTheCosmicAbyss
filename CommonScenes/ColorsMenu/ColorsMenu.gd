extends Node2D

var animator

func _ready():
	animator = get_node("AnimationPlayer")
	
	var menu_block = get_node("Menu/MenuRoot/MenusBlock")
	menu_block.current_menu = menu_block.current_menu


func _on_Exit_pressed():
	close()


func _on_Reset_pressed():
	pass # replace with function body


func close():
	if get_tree().get_current_scene() == self:
		var menu_root = get_node("Menu/MenuRoot")
		menu_root.hide()
		hide()
		
	else:
		ScreenManager.black_transition_from_above()


func _on_MenuWaves_activated():
	pass # replace with function body


func _on_MenuTentacles_activated():
	pass # replace with function body


func _on_MenuLaserEye_activated():
	pass # replace with function body


func _on_MenuBgBoss_activated():
	pass # replace with function body


func _on_MenuMidBoss_activated():
	pass # replace with function body


func _on_MenuFinalBoss_activated():
	pass # replace with function body


func _on_MenuFinalBoss1_activated():
	pass # replace with function body
