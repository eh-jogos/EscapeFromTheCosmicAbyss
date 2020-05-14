extends Node2D

onready var animator: AnimationPlayer = get_node("AnimationPlayer")
onready var legend_confirm_cancel = get_node("ColorsMenuLayer/MenuRoot/LegendConfirmCancel")
onready var legend_color_picker = get_node("ColorsMenuLayer/MenuRoot/LegendColorPicker")

func _ready() -> void:
	var menu_block = get_node("ColorsMenuLayer/MenuRoot/MenusBlock")
	menu_block.current_menu = menu_block.current_menu
	
	legend_confirm_cancel.show()
	legend_color_picker.hide()
	
	Global.connect("color_picker_opened", self, "_on_Global_color_picker_opened")
	Global.connect("color_picker_closed", self, "_on_Global_color_picker_closed")


func _unhandled_input(event) -> void:
	if event.is_action("ui_cancel"):
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("ui_cancel"):
		if legend_color_picker.visible:
			return
		
		var focus_button: Button = $ColorsMenuLayer/MenuRoot/NavButtons/Exit
		if focus_button.has_focus():
			_on_Exit_pressed()
		else:
			focus_button.grab_focus()


func close() -> void:
	Global.save()
	if get_tree().get_current_scene() == self:
		var menu_root = get_node("ColorsMenuLayer/MenuRoot")
		menu_root.hide()
		hide()
	else:
		ScreenManager.black_transition_from_above()


func _on_Reset_pressed() -> void:
	Global.read()
	Global.emit_signal("reset_color_pickers")
	get_tree().call_group("interactive_color", "colors_changed")


func _on_ResetDefaults_pressed() -> void:
	Global.reset_colors()
	Global.emit_signal("reset_color_pickers")
	get_tree().call_group("interactive_color", "colors_changed")


func _on_Exit_pressed() -> void:
	close()


func _on_MenuWaves_activated() -> void:
	if animator == null:
		return
	
	animator.play("base")


func _on_MenuTentacles_activated() -> void:
	if animator == null:
		return
	
	animator.play("tentacles")


func _on_MenuLaserEye_activated() -> void:
	if animator == null:
		return
	
	animator.play("laser_eye")


func _on_MenuBgBoss_activated() -> void:
	if animator == null:
		return
	
	animator.play("bg_boss")


func _on_MenuMidBoss_activated() -> void:
	if animator == null:
		return
	
	animator.play("mid_boss")


func _on_MenuFinalBoss_activated() -> void:
	if animator == null:
		return
	
	animator.play("final_boss_entrance")


func _on_MenuFinalBoss1_activated() -> void:
	if animator == null:
		return
	
	animator.play("final_boss_laser_loop")


func _on_Global_color_picker_opened() -> void:
	legend_confirm_cancel.hide()
	legend_color_picker.show()


func _on_Global_color_picker_closed() -> void:
	legend_confirm_cancel.show()
	legend_color_picker.hide()
