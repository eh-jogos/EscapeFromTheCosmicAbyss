extends KinematicBody2D

signal dashing(boolean)

export(int) var min_speed = 4

const OVERHEAT_THRESHOLD = 80

# OTHER SCENES TO BE PRELOADED
var bullet = preload("res://JetpackGameMode/Character/Bullet_RayCast.tscn")

# Outer Nodes I'll interact with
var game
var overheat_bar
var overheat_bar_animator
var points_label
var ammunition

# Inside Nodes I'll interact with
var jet_particles
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
var base_dash_cost = 65.0
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
	overheat_bar = game.get_node("HUD/TextureProgress")
	overheat_bar_animator = game.get_node("HUD/TextureProgress/AnimationPlayer")
	points_label = game.get_node("HUD/CenterArea/Points")
	ammunition = game.get_node("HUD/TextureProgress/Ammunition")
	
	# Inside Nodes
	jet_particles = self.get_node("JetParticles")
	body_animator = self.get_node("BodyAnimator")
	arms_animator = self.get_node("ArmsAnimator")
	bullet_spawn = self.get_node("BulletSpawn")
	shield = self.get_node("Shield")
	
	falling = true
	body_animator.play("falling")
	if not shooting:
		arms_animator.play("falling")
	
	overheat_bar_animator.play("base")
	
	set_fixed_process(true)
	set_process_input(true)
	pass

func _fixed_process(delta):
	if game.get_game_state() != game.STATE.Playing and game.get_game_state() != game.STATE.Tutorial:
		return
	
	var heat = game.get_overheat()
	if not dashing:
		heat -= cooldown if heat >= cooldown else 0
	
	handle_overheat_bar_color(heat)
	
	speed.y += delta * gravity_force
	
	if Input.is_action_pressed("boost") and not overheated:
		heat = handle_boost(delta, heat)
	else:
		jet_particles.set_emitting(false)
	
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
			emit_signal("dashing", dashing)
			speed.x += speed_x*unit.x*delta
			speed.x = clamp(speed.x, 0, speed_x*unit.x)
	else:
		speed.x += speed_x*unit.x*delta
		speed.x = clamp(speed.x, 0, speed_x*unit.x)
	
	game.set_overheat(heat)
	
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
	motion = self.move(motion)
	
	
	if self.is_colliding():
		
		var collider = get_collider()
		#print(collider.get_name())
		if collider.is_in_group("enemy") and not is_dead and shield_energy > 0:
			#print("Shield Protected")
			shield.decrease_energy(1)
			
			var normal = self.get_collision_normal()
			var final_motion = normal.slide(motion)
			
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
			
			self.move(final_motion)
			
		elif collider.is_in_group("enemy") and not is_dead:
			#print("Shield Energy at death: %s"%[shield_energy])
			is_dead = true
			game.set_game_state("GameOver")
			set_fixed_process(false)
			set_process_input(false)
			self.hide()
			
			var offset = self.get_global_pos()
			collider.kill_player(offset)
#			queue_free()
			
		else: 
			var normal = get_collision_normal()
			motion = normal.slide(motion)
			motion = self.move(motion)


func handle_overheat_bar_color(heat): 
	var is_already_playing = overheat_bar_animator.is_playing()
	if overheated and not is_already_playing:
		overheat_bar_animator.play("overheated")
	elif heat <= OVERHEAT_THRESHOLD and overheated and not is_already_playing:
		overheated = false
		overheat_bar_animator.play_backwards("overheated")
	elif heat > OVERHEAT_THRESHOLD-dash_cost and not undashable and not is_already_playing:
		overheat_bar_animator.play("undashable")
		undashable = true
	elif heat <= OVERHEAT_THRESHOLD-dash_cost and undashable and not is_already_playing:
		overheat_bar_animator.play_backwards("undashable")
		undashable = false


func handle_boost(delta, heat):
	jet_particles.set_emitting(true)
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
	
	return heat


func handle_dash(delta, dash_force, heat):
	dashing = true
	emit_signal("dashing", dashing)
	
	speed.x = (10*unit.x)+(dash_force*delta)
	#print("Node: %s | Speed.x: %s"%[self.get_name(), speed.x])
	speed.y = 0
	
	heat += dash_cost
	if heat >= 100:
		heat = 100
		overheated = true
	
	return heat



func _input(event):
	if game.get_game_state() != 0 and game.get_game_state() != 3:
		return
	
	if event.is_action_pressed("shoot") and ammunition.has_ammo() and not shooting:
		#game.dash_score()
		shooting = true
		ammunition.use_ammo()
		arms_animator.play("shooting")
		
		var new_bullet = bullet.instance()
		bullet_spawn.add_child(new_bullet)
		new_bullet.set_laser_strength(laser_strength)
		
		if not new_bullet.is_connected("laser_end",self, "stop_shooting"):
			new_bullet.connect("laser_end", self, "stop_shooting")

func stop_shooting():
	shooting = false
	arms_animator.play("reloading")
	yield(arms_animator,"finished")
	var current_anim = body_animator.get_current_animation()
	var current_anim_pos = body_animator.get_current_animation_pos()
	
	arms_animator.set_current_animation(current_anim)
	arms_animator.seek(current_anim_pos)
	if not arms_animator.is_active():
		arms_animator.set_active(true)

func rise_to_fall():
	body_animator.play("falling")
	if not shooting:
		arms_animator.play("falling")

func fall_to_rise():
	body_animator.play("rising")
	if not shooting:
		arms_animator.play("rising")

func shield_up(increment):
	shield.increase_energy(increment)

func score():
	
	game._on_scored(5)

func reset_y():
	speed.y = 0


func can_dash(heat):
	return not dashing and not overheated and heat < OVERHEAT_THRESHOLD-dash_cost


func set_player_stats():
	speed_x = min_speed + game.initial_speed
	shield_energy = game.initial_shield
	laser_strength = 1.5 + (0.5*game.laser_strength)
	cooldown = 1.5 + (0.1 * game.cooldown)
	dash_cost = base_dash_cost - (base_dash_cost * 0.15 * game.cooldown)
	
	print("SHIELD UP: %s"%[shield_energy])
	shield_up(shield_energy)
