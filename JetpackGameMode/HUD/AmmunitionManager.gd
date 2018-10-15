extends Node2D

# preloaded scenes
var ammo = preload("res://JetpackGameMode/HUD/Ammo.tscn")

# outer nodes
var game

#member variables
var current_slot = 0

# Limits
const TOTAL_SLOTS = 10

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func initialize_ammo(initial_ammo):
	for x in range(0,initial_ammo):
		add_ammo()

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