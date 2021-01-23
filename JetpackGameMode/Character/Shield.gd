tool
extends Area2D

export var call_method_increase_energy: = {"text": "Increase Energy", "arguments": [3]}
export var call_method_decrease_energy: = {"text": "Decrease Energy", "arguments": [3]}

# node variables
var player
var shield_animator

onready var shield_bubble = $ShieldBubble

# member variables
var energy = 0

# "Stats" Limits?
const MAX_SHIELD = 3

func _ready():
	player = self.get_parent()
	shield_animator = self.get_node("ShieldAnimator")
	
	shield_animator.play("disabled")

func modulate_shield(should_mute = false):
	var animation = shield_animator.assigned_animation
	#print("MODULATE SHIELD | Energy:%s"%[energy])
	
	if not should_mute and energy != 0:
		var sfx_player = $SfxLibrary/ShieldUp
		sfx_player.play()
	
	if energy == 0:
		shield_animator.play("disabled")
	
	if not Engine.editor_hint:
		player.shield_energy = energy


func increase_energy(increment, should_mute = false):
	for _index in range(1, increment + 1):
		energy = min(energy + 1, MAX_SHIELD)
		
		if shield_bubble.energy != energy:
			Global.emit_signal("shield_energy_updated_to", energy)
			print("Shield Energy: %s | Incremet: %s"%[energy,increment])
			
			shield_animator.play("open")
			modulate_shield(should_mute)
			shield_bubble.energy = energy
			yield(shield_animator, "animation_finished")
		else:
			Global.game._on_scored(5)

func decrease_energy(increment):
	for _index in range(1, increment + 1):
		energy = max(energy - 1, 0)
		
		if shield_bubble.energy != energy:
			Global.emit_signal("shield_energy_updated_to", energy)
			print("Shield Energy: %s | Incremet: %s"%[energy,increment])
			
			shield_animator.play("burst")
			yield(shield_animator, "animation_finished")
			modulate_shield(true)
			shield_bubble.energy = energy
