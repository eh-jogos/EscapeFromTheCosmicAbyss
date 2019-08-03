extends AnimatedSprite

var animator

var count = 0

var laser_index = 0
var animation_index = 0
var laser_targets = []
var animation_targets = []
var animations = []

var current_laser_target
var current_animation_target
var current_animation


func _ready():
	animator = get_node("AnimationPlayer")


func set_boss_data(laser_targets, animation_targets, animations):
	self.laser_targets = laser_targets
	self.animation_targets = animation_targets
	self.animations = animations
	
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
		else:
			print("BackgroundBoss | _on_beat_spawned | Invalid animation key: %s"%[current_animation])
			assert(false)
		
		animation_index += 1
		if animation_index < animation_targets.size():
			set_current_animation_variables()
	elif current_laser_target != null and count == current_laser_target:
		var is_up = randi()%2
		if is_up:
			animator.play("laser_charge_up")
		else:
			animator.play("laser_charge_down")
		
		laser_index += 1
		if laser_index < laser_targets.size():
			set_current_laser()
		
		print("BackgroundBoss | _on_beat_spawned | LASER! | is_up: %s"%[is_up])