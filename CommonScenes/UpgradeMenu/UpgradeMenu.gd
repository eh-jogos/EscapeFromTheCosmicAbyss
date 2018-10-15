extends CanvasLayer

var initial_btn
var animator

# Stats Variables imported from savedata
var cooldown
var initial_shield
var initial_ammo
var initial_speed
var max_speed
var laser_duration
var upgrade_points

# Stats Bars
var cooldown_bar
var shield_bar
var ammo_bar
var initial_speed_bar
var max_speed_bar
var laser_bar
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

func init_story_store():
	cooldown = Global.savedata["story"]["cooldown"]
	initial_shield = Global.savedata["story"]["initial shield"]
	initial_ammo = Global.savedata["story"]["initial ammo"]
	initial_speed = Global.savedata["story"]["initial speed"]
	max_speed = Global.savedata["story"]["max speed"]
	laser_duration = Global.savedata["story"]["laser duration"]
	upgrade_points = Global.savedata["story"]["upgrade points"]
	
	#upgrade_points -= 30
	#upgrade_points = clamp(upgrade_points, 0, 59)
	up_label.set_text(str(upgrade_points))
	
	init_bar(cooldown_bar, cooldown)
	init_bar(shield_bar, initial_shield)
	init_bar(ammo_bar, initial_ammo)
	init_bar(initial_speed_bar, initial_speed)
	init_bar(max_speed_bar, max_speed)
	init_bar(laser_bar, laser_duration)

func init_arcade_store():
	pass

func init_speedrun_store():
	pass

func _on_SaveApply_pressed():
	init_bar(cooldown_bar, cooldown)
	init_bar(shield_bar, initial_shield)
	init_bar(ammo_bar, initial_ammo)
	init_bar(initial_speed_bar, initial_speed)
	init_bar(max_speed_bar, max_speed)
	init_bar(laser_bar, laser_duration)
	
	Global.update_story_stats(cooldown, initial_ammo, initial_shield, initial_speed, max_speed, laser_duration, upgrade_points)

func _on_Reset_pressed():
	var store_mode = Global.get_game_mode()
	if store_mode == "story":
		init_story_store()
	elif store_mode == "arcade":
		init_arcade_store()
	elif store_mode == "speedrun":
		init_speedrun_store()
	else:
		print("ERROR | Unexpected Store Mode: %s"%[store_mode])
		init_story_store()

func _on_Close_pressed():
	_on_Reset_pressed()
	animator.play("close")
	yield(animator,"finished")
	ScreenManager.clear_above()

##################
# Engine Methods #
##################

func _ready():
	initial_btn = get_node("SectionLabels/Cooldown")
	initial_btn.grab_focus()
	
	animator = self.get_node("AnimationPlayer")
	
	cooldown_bar = get_node("SectionLabels/Cooldown/UpgradeBar")
	shield_bar = get_node("SectionLabels/Shields/UpgradeBar")
	ammo_bar = get_node("SectionLabels/StartingAmmo/UpgradeBar")
	initial_speed_bar = get_node("SectionLabels/StartSpeed/UpgradeBar")
	max_speed_bar = get_node("SectionLabels/MaxSpeed/UpgradeBar")
	laser_bar = get_node("SectionLabels/LaserDuration/UpgradeBar")
	up_label = get_node("SectionLabels/PointsNumber")
	
	_on_Reset_pressed()
	
	animator.play_backwards("close")
	
	pass