extends CanvasLayer

var initial_btn
var save_btn
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
var stat_bars = []

var up_label


####################
# Internal Methods #
####################

func init_bar(bar_node, bar_stat):
	var max_stats = bar_node.get_child_count()
	
	if bar_stat <= max_stats:
		for stat in range(0,max_stats):
			var slot = bar_node.get_child(stat)
			if stat < bar_stat:
				if is_extra_mode():
					slot.pending_upgrade()
				else:
					slot.apply_upgrade()
			else:
				slot.base_slot()
	else:
		for stat in range(0,max_stats):
			var slot = bar_node.get_child(stat)
			slot.apply_upgrade()
		
		print("ERROR | Saved Stat is bigger than Max Stat")
		print("%s | Saved Stat: %s | Max Stat %s"%[bar_node.get_parent().get_name(), bar_stat, max_stats])
	pass

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
	
	init_bar(cooldown_bar, cooldown)
	init_bar(shield_bar, initial_shield)
	init_bar(ammo_bar, initial_ammo)
	init_bar(initial_speed_bar, initial_speed)
	init_bar(max_speed_bar, max_speed)
	init_bar(laser_bar, laser_strength)


func _on_SaveApply_pressed():
	init_bar(cooldown_bar, cooldown)
	init_bar(shield_bar, initial_shield)
	init_bar(ammo_bar, initial_ammo)
	init_bar(initial_speed_bar, initial_speed)
	init_bar(max_speed_bar, max_speed)
	init_bar(laser_bar, laser_strength)
	
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
		upgrade_progress.show()
		upgrade_progress.set_max(max_progress_value)
		upgrade_progress.set_value(current_progress_value)
		init_store(store["game mode"])
	elif is_extra_mode():
		upgrade_progress.hide()
		init_store(store["game mode"])
	else:
		print("ERROR | Unexpected Store Mode: %s"%[store])
		init_store("story")

func _on_Close_pressed():
	_on_SaveApply_pressed()
	
	animator.play("close")
	yield(animator,"finished")
	
	
	if is_story_mode():
		ScreenManager.clear_above()
	elif is_extra_mode():
		var game = get_tree().get_root().get_node("JetpackGame")
		game.game_start()
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
	
	upgrade_progress = get_node("SectionLabels/ProgressBar")
	close_btn = get_node("Buttons/Close")
	save_btn = get_node("Buttons/SaveApply")
	initial_btn = get_node("SectionLabels/Cooldown")
	initial_btn.grab_focus()
	
	animator = self.get_node("AnimationPlayer")
	animator.set_current_animation("base")
	animator.seek(0,true)
	
	if is_extra_mode():
		close_btn.set_text("Start")
		save_btn.set_disabled(true)
		save_btn.hide()
	else:
		close_btn.set_text("Close")
		save_btn.set_disabled(false)
		save_btn.show()
	
	cooldown_bar = get_node("SectionLabels/Cooldown/UpgradeBar")
	stat_bars.append(cooldown_bar)
	
	shield_bar = get_node("SectionLabels/Shields/UpgradeBar")
	stat_bars.append(shield_bar)
	
	ammo_bar = get_node("SectionLabels/StartingAmmo/UpgradeBar")
	stat_bars.append(ammo_bar)
	
	initial_speed_bar = get_node("SectionLabels/StartSpeed/UpgradeBar")
	stat_bars.append(initial_speed_bar)
	
	max_speed_bar = get_node("SectionLabels/MaxSpeed/UpgradeBar")
	stat_bars.append(max_speed_bar)
	
	laser_bar = get_node("SectionLabels/LaserStrength/UpgradeBar")
	stat_bars.append(laser_bar)
	
	up_label = get_node("SectionLabels/PointsNumber")
	
	_on_Reset_pressed()
	
	animator.play_backwards("close")
	
	pass