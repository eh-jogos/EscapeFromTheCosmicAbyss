extends CanvasLayer

var initial_btn
var close_btn
var upgrade_progress
var animator
var store

# Stats Variables imported from savedata
var cooldown
var initial_shield
var initial_ammo
var initial_speed
var max_speed
var laser_strength
var upgrade_points

# Stats Bars
var cooldown_bar
var shield_bar
var ammo_bar
var initial_speed_bar
var max_speed_bar
var laser_bar

var up_label

var is_closing = false

####################
# Internal Methods #
####################

func init_store(game_mode):
	cooldown = Global.savedata[game_mode]["cooldown"]
	initial_shield = Global.savedata[game_mode]["initial shield"]
	initial_ammo = Global.savedata[game_mode]["initial ammo"]
	initial_speed = Global.savedata[game_mode]["initial speed"]
	max_speed = Global.savedata[game_mode]["max speed"]
	laser_strength = Global.savedata[game_mode]["laser strength"]
	upgrade_points = Global.savedata[game_mode]["upgrade points"]
	
	#upgrade_points -= 30
	#upgrade_points = clamp(upgrade_points, 0, 59)
	up_label.set_text(str(upgrade_points))
	
	get_node("SectionLabels/StartingAmmo").validate_stat_value()
	
	cooldown_bar.init_bar(cooldown, is_extra_mode())
	shield_bar.init_bar(initial_shield, is_extra_mode())
	ammo_bar.init_bar(initial_ammo, is_extra_mode())
	initial_speed_bar.init_bar(initial_speed, is_extra_mode())
	max_speed_bar.init_bar(max_speed, is_extra_mode())
	laser_bar.init_bar(laser_strength, is_extra_mode())


func _on_SaveApply_pressed():
	cooldown_bar.init_bar(cooldown, is_extra_mode())
	shield_bar.init_bar(initial_shield, is_extra_mode())
	ammo_bar.init_bar(initial_ammo, is_extra_mode())
	initial_speed_bar.init_bar(initial_speed, is_extra_mode())
	max_speed_bar.init_bar(max_speed, is_extra_mode())
	laser_bar.init_bar(laser_strength, is_extra_mode())
	
	if is_story_mode():
		Global.update_story_stats(cooldown, initial_ammo, initial_shield, initial_speed, max_speed, laser_strength, upgrade_points)
	elif is_extra_mode():
		Global.update_category_stats(store["game mode"], cooldown, initial_ammo, initial_shield, initial_speed, max_speed, laser_strength, upgrade_points)
	else:
		print("ERROR | Unexpected Store Mode: %s"%[store])

func _on_Reset_pressed():
	if is_story_mode():
		var max_progress_value = Global.calculate_next_upgrade()
		var current_progress_value = max_progress_value - Global.savedata["story"]["next upgrade"]
		upgrade_progress.set_max(max_progress_value)
		upgrade_progress.set_value(current_progress_value)
		init_store(store["game mode"])
	elif is_extra_mode():
		init_store(store["game mode"])
	else:
		print("ERROR | Unexpected Store Mode: %s"%[store])
		init_store("story")

func _on_Close_pressed():
	if is_closing:
		return
	
	is_closing = true
	_on_SaveApply_pressed()
	
	animator.play("close")
	yield(animator, "animation_finished")
	
	
	if is_story_mode():
		ScreenManager.clear_above()
	elif is_extra_mode():
		Global.game.game_start()
		ScreenManager.clear_above()

func is_extra_mode():
	return store["game mode"] == "arcade" or store["game mode"] == "speedrun"

func is_story_mode():
	return store["game mode"] == "story"

##################
# Engine Methods #
##################

func _ready():
	store = Global.get_game_mode()
	
	upgrade_progress = get_node("SectionLabels/NextGroup/ProgressBar")
	close_btn = get_node("Buttons/Confirm")
	initial_btn = get_node("SectionLabels/Cooldown")
	initial_btn.grab_focus()
	
	animator = self.get_node("AnimationPlayer")
	animator.assigned_animation = "base"
	animator.seek(0,true)
	
	var next_group = $SectionLabels/NextGroup
	if is_extra_mode():
		close_btn.set_text("   Start")
		next_group.hide()
	else:
		close_btn.set_text("   Confirm")
		next_group.show()
	
	cooldown_bar = get_node("SectionLabels/Cooldown")
	shield_bar = get_node("SectionLabels/Shields")
	ammo_bar = get_node("SectionLabels/StartingAmmo")
	initial_speed_bar = get_node("SectionLabels/StartSpeed")
	max_speed_bar = get_node("SectionLabels/MaxSpeed")	
	laser_bar = get_node("SectionLabels/LaserStrength")
	
	up_label = get_node("SectionLabels/PointsNumber")
	
	_on_Reset_pressed()
	
	animator.play_backwards("close")


func _unhandled_input(event) -> void:
	if event.is_action("ui_cancel") or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
	
	if event.is_action_pressed("ui_cancel"):
		_on_Reset_pressed()
	
	if event.is_action_pressed("ui_accept"):
		_on_Close_pressed()
