extends Node2D

var animator

var count = 0

var laser_index = 0
var animation_index = 0
var laser_targets = []
var animation_targets = []
var animations = []
var danger_durations = []

var current_laser_target
var current_animation_target
var current_animation
var current_danger_duration
var up_down_count = 0


func _ready():
	animator = get_node("AnimationPlayer")
	up_down_count = randi()%2


# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
func set_boss_data(laser_targets, animation_targets, animations, danger):
	self.laser_targets = laser_targets
	self.animation_targets = animation_targets
	self.animations = animations
	self.danger_durations = danger
	
	set_current_laser()
	set_current_animation_variables()


func set_current_laser():
	if laser_targets.size() > 0:
		current_laser_target = laser_targets[laser_index]
	else:
		current_laser_target = null


func set_current_animation_variables():
	current_animation_target = animation_targets[animation_index]
	current_animation = animations[animation_index]
	current_danger_duration = danger_durations[animation_index]


func restart_count():
	count = 0
	laser_index = 0
	animation_index = 0
	set_current_laser()
	set_current_animation_variables()
	animator.play("base")


func _on_beat_spawned():
	count += 1
	if count == current_animation_target:
		if animator.has_animation(current_animation):
			print("BackgroundBoss | _on_beat_spawned | Animation! | key: %s"%[current_animation])
			animator.play(current_animation)
			Global.emit_signal("start_danger", current_danger_duration)
		else:
			print("BackgroundBoss | _on_beat_spawned | Invalid animation key: %s"%[current_animation])
			assert(false)
		
		animation_index += 1
		if animation_index < animation_targets.size():
			set_current_animation_variables()
	elif current_laser_target != null and count == current_laser_target:
		var is_up = up_down_count % 2
		if is_up:
			animator.play("laser_charge_up")
		else:
			animator.play("laser_charge_down")
		
		up_down_count += 1
		laser_index += 1
		if laser_index < laser_targets.size():
			set_current_laser()
		
		print("BackgroundBoss | _on_beat_spawned | LASER! | is_up: %s"%[is_up])


func _check_scream_achievement():
	Global.achievements_handler.increment_screams_heard()
