extends Node2D

var animator

var count = 0

var laser_index = 0
var animation_index = 0

var current_laser_target: int = -1
var current_animation_target: int = -1
var current_animation: String = ""
var current_danger_duration: int = -1
var up_down_count = 0

var _boss_data: BossData = null


func _ready():
	animator = get_node("AnimationPlayer")
	up_down_count = randi()%2



func set_boss_data(p_boss_data: BossData):
	_boss_data = p_boss_data
	set_current_laser()
	set_current_animation_variables()


func set_current_laser():
	if _boss_data.laser_countdown.size() > 0:
		current_laser_target = _boss_data.laser_countdown[laser_index]
	else:
		current_laser_target = -1


func set_current_animation_variables():
	current_animation_target = _boss_data.animation_countdowns[animation_index]
	current_animation = _boss_data.animation_names[animation_index]
	current_danger_duration = _boss_data.danger_durations[animation_index]


func restart_count():
	count = 0
	laser_index = 0
	animation_index = 0
	set_current_laser()
	set_current_animation_variables()
	animator.play("base")


func shake_camera(trauma: float) -> void:
	Global.shake_trauma_added.emit(trauma)


func _on_beat_spawned():
	count += 1
	if count == current_animation_target:
		if animator.has_animation(current_animation):
			print("BackgroundBoss | _on_beat_spawned | Animation! | key: %s"%[current_animation])
			animator.play(current_animation)
			Global.start_danger.emit(current_danger_duration)
		else:
			print("BackgroundBoss | _on_beat_spawned | Invalid animation key: %s"%[current_animation])
			assert(false)
		
		animation_index += 1
		if animation_index < _boss_data.animation_countdowns.size():
			set_current_animation_variables()
	elif current_laser_target > 0 and count == current_laser_target:
		var is_up = up_down_count % 2
		if is_up:
			animator.play("laser_charge_up")
		else:
			animator.play("laser_charge_down")
		
		up_down_count += 1
		laser_index += 1
		if laser_index < _boss_data.laser_countdown.size():
			set_current_laser()
		
		print("BackgroundBoss | _on_beat_spawned | LASER! | is_up: %s"%[is_up])


func _check_scream_achievement():
	Global.achievements_handler.increment_screams_heard()
