extends AnimatedSprite

var animator

var count = 0

var target_index = 0
var count_targets = []
var animations = []

var current_target
var current_animation


func _ready():
	animator = get_node("AnimationPlayer")


func set_bg_boss_data(count_targets, animations):
	self.count_targets = count_targets
	self.animations = animations
	
	set_current_variables()


func set_current_variables():
	current_target = count_targets[target_index]
	current_animation = animations[target_index]


func restart_count():
	count = 0
	target_index = 0
	set_current_variables()
	animator.play("base")


func _on_beat_spawned():
	count += 1
	if count == current_target:
		animator.play(current_animation)
		target_index += 1
		if target_index < count_targets.size():
			set_current_variables()