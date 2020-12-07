extends KinematicBody2D

signal dashing(boolean)

export(int) var min_speed = 4
export(bool) var is_invincible = false

const OVERHEAT_THRESHOLD = 80

# OTHER SCENES TO BE PRELOADED
var bullet = preload("res://JetpackGameMode/Character/Bullet_RayCast.tscn")

# Outer Nodes I'll interact with
var game
var overheat_bar
var overheat_bar_animator
var points_label

# Inside Nodes I'll interact with
var jet_particles
var dash_particles: Particles2D
var jet_sfx
var body_animator
var arms_animator
var bullet_spawn
var shield

# Player FLAGS?
var overheated = false
var undashable = false
var dashing = false
var is_dead = false
var falling = true
var shooting = false
var is_bouncing = false


# "Stats" Variables?
var gravity = 1200.0
var speed_y = -900.0
var dash_modifier = 90.0
var base_dash_cost = 50
var dash_cost_decrement = 6.4 # so that at max upgrade, dash cost is 18
var dash_cost
var speed_x 
var shield_energy
var laser_strength
var cooldown

# My base character sprite. Will serve as units for the forces
var unit = Vector2(97.0,89.0)

var gravity_force = 40.0*unit.y
var jetpack_force = -90.0*unit.y

var speed = Vector2(0, 0)

func _ready():
	# Outer Nodes
	game = self.get_parent()
	overheat_bar = get_node("OverheatBar")
	overheat_bar_animator = get_node("OverheatBar/AnimationPlayer")
	points_label = game.get_node("HUD/CenterArea/Points")
	
	# Inside Nodes
	jet_particles = self.get_node("Skin/JetParticles")
	jet_sfx = jet_particles.get_node("SamplePlayer")
	dash_particles = get_node("Skin/FinalSkin/DashParticles")
	dash_particles.emitting = false
	body_animator = self.get_node("BodyAnimator")
	arms_animator = self.get_node("ArmsAnimator")
	bullet_spawn = self.get_node("Skin/BulletSpawn")
	shield = self.get_node("Shield")
	
	falling = true
	body_animator.play("falling")
	if not shooting:
		arms_animator.play("falling")
	
	overheat_bar_animator.play("base")
	
	set_physics_process(true)
	set_process_input(true)
	
	Global.connect("update_invincibility", self, "_on_update_invincibility")
	if OS.is_debug_build():
		if Global.is_invincible:
			is_invincible = Global.is_invincible
	else:
		is_invincible = Global.is_invincible


func _physics_process(delta):
	if game.get_game_state() != game.STATE.Playing and game.get_game_state() != game.STATE.Tutorial:
		return
	
	SoundManager.reset_ui_bus_effects()
	
	var heat = overheat_bar.get_value()
	if not dashing:
		heat = max(heat-cooldown, 0)
	
	handle_overheat_bar_color(heat)
	
	speed.y += delta * gravity_force
	
	if Input.is_action_pressed("boost") and not overheated and not dashing:
		heat = handle_boost(delta, heat)
	else:
		jet_particles.set_emitting(false)
		if jet_sfx.playing:
			jet_sfx.stop()
	
	var dash_force = speed_x*dash_modifier*unit.x
	
	if Input.is_action_pressed("dash"):
		if can_dash(heat):
	#		print("DASH!")
			heat = handle_dash(delta, dash_force, heat)
		elif not overheated and not dashing:
			heat = handle_boost(delta, heat)
	
	if dashing:
		if speed.x > speed_x*unit.x:
			speed.x -= (dash_force/20)*delta
#			print(speed.x)
			speed.y = 0
		else:
			dashing = false
			dash_particles.emitting = dashing
			emit_signal("dashing", dashing)
			speed.x += speed_x*unit.x*delta
			speed.x = clamp(speed.x, 0, speed_x*unit.x)
	else:
		speed.x += speed_x*unit.x*delta
		speed.x = clamp(speed.x, 0, speed_x*unit.x)
	
	overheat_bar.set_value(heat)
	
	if is_bouncing:
		speed.y = clamp(speed.y, speed_y*5, gravity)
		is_bouncing = false
	else:
		speed.y = clamp(speed.y, speed_y, gravity)
	#print(speed.y)
	
	if speed.y > 0 and not falling:
		falling = true
		body_animator.play("rise_to_fall")
		if not shooting:
			arms_animator.play("rise_to_fall")
	
	var motion = speed * delta
	#print("Motion: %s"%[motion])
	var collision = self.move_and_collide(motion)
	
	if collision != null:
		
		motion = collision.remainder
		var collider = collision.collider
		#print(collider.get_name())
		if collider.is_in_group("enemy") and not is_dead and shield_energy > 0:
			#print("Shield Protected")
			take_hit()
			
			var normal = collision.normal
			var final_motion = motion.slide(normal)
			
			if collider.has_method("die"):
				collider.die()
			else:
				if speed.y > 0:
					speed.y *= -5
					is_bouncing = true
					#print("Falling | speed.y: %s"%[speed.y])
				else:
					speed.y *= -2
					#print("Rising | speed.y: %s"%[speed.y])
			
			self.move_and_slide(final_motion)
			
		elif collider.is_in_group("enemy") and not is_dead and not is_invincible:
			#print("Shield Energy at death: %s"%[shield_energy])
			is_dead = true
			game.set_game_state("GameOver")
			set_physics_process(false)
			set_process_input(false)
			self.hide()
			
			var offset = self.global_position
			collider.kill_player(offset)
#			queue_free()
			
		else: 
			var normal = collision.normal
			motion = normal.slide(motion)
			motion = self.move_and_slide(motion)


func handle_overheat_bar_color(heat): 
	var current_animation = overheat_bar_animator.assigned_animation
	var overheat_relief_point = min(OVERHEAT_THRESHOLD, 100-dash_cost)
	if overheated and heat > 100-dash_cost:
		if current_animation != "overheated":
			overheat_bar_animator.play("overheated")
	elif heat <= overheat_relief_point and overheated:
		overheated = false
		overheat_bar_animator.assigned_animation = "undashable"
		overheat_bar_animator.seek(overheat_bar_animator.current_animation_length, true)
	elif heat > OVERHEAT_THRESHOLD-dash_cost and not undashable:
		overheat_bar_animator.play("undashable")
		undashable = true
	elif can_dash(heat) and undashable:
		overheat_bar_animator.play("base")
		undashable = false


func handle_boost(delta, heat):
	jet_particles.set_emitting(true)
	if not jet_sfx.playing:
		jet_sfx.play()
	
	if falling: 
		falling = false
		body_animator.play("fall_to_rise")
		if not shooting:
			arms_animator.play("fall_to_rise")
	
	speed.y += jetpack_force*delta
	
	heat += 2.3
	if heat >= 100:
		heat = 100
		overheated = true
		dashing = false
		dash_particles.emitting = dashing
	
	return heat


func handle_dash(delta, dash_force, heat):
	dashing = true
	emit_signal("dashing", dashing)
	
	var dash_sfx = $SfxLibrary/Dash
	dash_sfx.play()
	
	speed.x = (10*unit.x)+(dash_force*delta)
	#print("Node: %s | Speed.x: %s"%[self.get_name(), speed.x])
	speed.y = 0
	
	heat += dash_cost
	if heat >= 100:
		heat = 100
		overheated = true
		dashing = false
	
	dash_particles.emitting = dashing
	
	return heat



func _input(event):
	if game.get_game_state() != 0 and game.get_game_state() != 3:
		return
	
	if event.is_action_pressed("shoot") and game.ammunition.has_ammo() and not shooting:
		#game.dash_score()
		shooting = true
		game.ammunition.use_ammo()
		arms_animator.play("shooting")
		
		var new_bullet = bullet.instance()
		bullet_spawn.add_child(new_bullet)
		new_bullet.set_laser_strength(laser_strength)
		
		if not new_bullet.is_connected("laser_end",self, "stop_shooting"):
			new_bullet.connect("laser_end", self, "stop_shooting")

func stop_shooting():
	shooting = false
	arms_animator.play("reloading")
	yield(arms_animator, "animation_finished")
	var current_anim = body_animator.assigned_animation
	var current_anim_pos = body_animator.current_animation_position
	
	arms_animator.assigned_animation = current_anim
	arms_animator.seek(current_anim_pos)
	if not arms_animator.is_playing():
		arms_animator.play(current_anim)

func rise_to_fall():
	body_animator.play("falling")
	if not shooting:
		arms_animator.play("falling")

func fall_to_rise():
	body_animator.play("rising")
	if not shooting:
		arms_animator.play("rising")

func shield_up(increment, should_mute = false):
	shield.increase_energy(increment, should_mute)

func reset_y():
	speed.y = 0


func can_dash(heat):
	return not dashing and not overheated and heat <= OVERHEAT_THRESHOLD-dash_cost 


func set_player_stats(is_tutorial: bool):
	speed_x = min_speed + game.initial_speed
	if is_tutorial:
		shield_energy = 0
	else:
		shield_energy = game.initial_shield
	laser_strength = 1.5 + (0.5*game.laser_strength)
	cooldown = 1.0 + (0.14 * game.cooldown)
	dash_cost = base_dash_cost - (dash_cost_decrement * game.cooldown)
	
	if is_invincible and shield_energy == 0:
			shield_energy = 1
	
	print("SHIELD UP: %s"%[shield_energy])
	shield_up(shield_energy, true)


func take_hit():
	if is_invincible and shield_energy <= 1:
		return
	
	shield.decrease_energy(1)


func _on_update_invincibility():
	is_invincible = Global.is_invincible
	if is_invincible and shield.energy == 0:
		shield_up(1)
