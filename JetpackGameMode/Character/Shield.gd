extends Area2D

# node variables
var player
var shield_animator
var shield_sprite

# member variables
var energy = 0

# "Stats" Limits?
const MAX_SHIELD = 3

func _ready():
	player = self.get_parent()
	shield_animator = self.get_node("ShieldAnimator")
	shield_sprite = self.get_node("Sprite")
	
	shield_animator.play("disabled")

func modulate_shield(should_mute = false):
	var animation = shield_animator.get_current_animation()
	#print("MODULATE SHIELD | Energy:%s"%[energy])
	
	if not should_mute and energy != 0:
		var sfx_player = $SfxLibrary/ShieldUp
		sfx_player.play()
	
	if energy == 0:
		shield_animator.play("disabled")
	elif energy == 1:
		shield_sprite.set_modulate(Color(0,0.96,1,1))
		shield_animator.play("open")
	elif energy == 2:
		shield_sprite.set_modulate(Color(0.6,0.27,1,1))
		if animation == "burst" or animation == "disabled":
			shield_animator.play("open")
	elif energy == 3:
		shield_sprite.set_modulate(Color(0.84,0,1,1))
		if animation == "burst" or animation == "disabled":
			shield_animator.play("open")
	else:
		print("SHIELD ERROR | UNKNOW VALUE OF ENERGY: %s"%[energy])
	
	player.shield_energy = energy

func increase_energy(increment, should_mute = false):
	if energy+increment > MAX_SHIELD:
		energy = MAX_SHIELD
		player.score()
	elif energy+increment <= MAX_SHIELD:
		energy += increment
	else:
		print("SHIELD ERROR | UNKNOW VALUE OF INCREMENT: %s"%[increment])
	
	Global.emit_signal("shield_energy_updated_to", energy)
	print("Shield Energy: %s | Incremet: %s"%[energy,increment])
	
	modulate_shield(should_mute)

func decrease_energy(increment):
	if energy-increment < 0:
		energy = 0
	elif energy-increment >= 0:
		energy -= increment
	else:
		print("SHIELD ERROR | UNKNOW VALUE OF INCREMENT: %s"%[increment])
	
	Global.emit_signal("shield_energy_updated_to", energy)
	shield_animator.play("burst")
	yield(shield_animator, "animation_finished")
	modulate_shield()
