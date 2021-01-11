extends HBoxContainer

# preloaded scenes
var ammo_packed_scene = preload("res://JetpackGameMode/HUD/Ammo.tscn")

# Limits
const TOTAL_SLOTS = 10


func initialize_ammo(initial_ammo):
	for _x in range(0,initial_ammo):
		add_ammo()


func is_maxed_out() -> bool:
	return get_child_count() >= TOTAL_SLOTS


func add_ammo():
	if is_maxed_out(): 
		return
	
	var instance = ammo_packed_scene.instance()
	add_child(instance, true)


func has_ammo():
	if get_child_count() == 0: 
		return false
	else:
		return true


func use_ammo():
	if get_child_count() == 0 : 
		return false
	
	var ammo = get_child(0)
	
	ammo.used()
	
	return true


func _on_Ammunition_sort_children():
	if get_child_count() == 0:
		hide()
	else:
		show()
