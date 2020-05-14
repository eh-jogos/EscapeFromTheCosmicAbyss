extends CanvasLayer
class_name BaseLegend
# Write your doc striing for this file here

### Member Variables and Dependencies -----
# signals 
# enums
# constants
# public variables - order: export > normal var > onready 
var visible: = false

# private variables - order: export > normal var > onready 
onready var _animator: AnimationPlayer = $AnimationPlayer

### ---------------------------------------


### Built in Engine Methods ---------------
func _ready() -> void:
	_animator.connect("animation_finished", self, "_on_animator_animation_finished")
### ---------------------------------------


### Public Methods ------------------------
func fade_in() -> void:
	_animator.play("fade_in")


func fade_out() -> void:
	_animator.play("fade_out")


func show() -> void:
	_animator.play("editor")


func hide() -> void:
	_animator.play("base")

### ---------------------------------------


### Private Methods -----------------------
func _on_animator_animation_finished(anim_name: String) -> void:
	match anim_name:
		"fade_in", "editor":
			visible = true
		"fade_out", "base":
			visible = false
		_:
			push_error("Uregistered animation: %s"%[anim_name])
			assert(false)
### ---------------------------------------


