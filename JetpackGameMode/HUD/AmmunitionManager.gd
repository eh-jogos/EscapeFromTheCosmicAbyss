extends Node2D


var ammo = preload("res://JetpackGameMode/HUD/Ammo.tscn")

const TOTAL_SLOTS = 10

var current_slot = 0
var initial_ammo = 5

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	for x in range(0,initial_ammo):
		add_ammo()
	pass

func add_ammo():
	if current_slot >= TOTAL_SLOTS: return
	var slot = self.get_child(current_slot)
	var instance = ammo.instance()
	slot.add_child(instance)
	current_slot += 1

func use_ammo():
	if current_slot == 0 : return false
	var slot = self.get_child(current_slot-1)
	var ammo = slot.get_child(0)
	
	ammo.used()
	
	current_slot -= 1
	
	return true