extends Node2D

const POSITION_Y = -472

export(int) var point_value = 5

var is_tracking = true
var animator
var game

var raycast_left
var raycast_middle
var raycast_right

var should_score = true

func _ready():
	position = Vector2(0, POSITION_Y)
	animator = get_node("AnimationPlayer")
	game = get_tree().get_root().get_node("JetpackGame")
	
	set_physics_process(false)
	
	animator.set_current_animation("hidden")
	animator.seek(0,true)
	
	raycast_left = get_node("Root/Raycasts/Left")
	raycast_middle = get_node("Root/Raycasts/Middle")
	raycast_right = get_node("Root/Raycasts/Right")


func _physics_process(delta):
	if is_tracking:
		global_position = Vector2(get_parent().player_position.x -480, global_position.y)
	else:
		global_position = global_position

	if raycast_middle.is_colliding():
		handle_collision(raycast_middle)
	elif raycast_right.is_colliding():
		handle_collision(raycast_right)
	elif raycast_left.is_colliding():
		handle_collision(raycast_left)


func handle_collision(raycast):
	var collider = raycast.get_collider()
	#print("LaserEye | Raycast: %s | Collider: %s" %[raycast.get_name(), collider.get_name()])
	if collider.is_in_group("player"):
		set_physics_process(false)
		should_score = false
		if not collider.is_dead and collider.shield_energy > 0:
			collider.take_hit()
		elif not collider.is_dead:
			var offset = collider.global_position
			kill_player(offset)


func start():
	animator.play("enter")
	is_tracking = true
	set_physics_process(true)


func stop_tracking():
	#print("STOP TRACKING! DODGE")
	is_tracking = false


func kill_player(offset):
	#play player killing animation here in the future, if you want/have to
	#at the end of that animation, either from a signal or by calling it directly, call _on_player_killed
	_on_player_killed()

func _on_player_killed():
	game.game_over()

func _on_cycle_ended():
	set_physics_process(false)
	if should_score:
		game._on_scored(point_value)


func stop_all_sfx():
	var sfx_player = get_node("SamplePlayer")  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	# sfx_player.stop()
