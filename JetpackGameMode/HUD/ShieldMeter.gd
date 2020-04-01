extends Control

var shield = preload("res://JetpackGameMode/HUD/ShiedIcon.tscn")


func _ready():
	Global.connect("shield_energy_updated_to", self, "_on_Global_shield_energy_updated_to")


func _on_Global_shield_energy_updated_to(amount):
	var current_shield_amount = get_child_count()
	if amount > current_shield_amount:
		var limit = amount - current_shield_amount
		for _index in range(limit):
			var new_shield = shield.instance()
			add_child(new_shield, true)
			new_shield.play_intro()
	elif amount < current_shield_amount:
		var limit = current_shield_amount - amount
		var shields = get_children()
		for _index in range(limit):
			shields[-1].use_shield()
			shields.pop_back()