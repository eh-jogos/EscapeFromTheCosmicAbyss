extends Control
# Write your doc striing for this file here

### Member Variables and Dependencies -----
# signals 
# enums
# constants
# public variables - order: export > normal var > onready 
# private variables - order: export > normal var > onready 
onready var _animator: AnimationPlayer = $AnimationPlayer

### ---------------------------------------


### Built in Engine Methods ---------------
### ---------------------------------------


### Public Methods ------------------------
func fade_in() -> void:
	_animator.play("fade_in")


func fade_out() -> void:
	_animator.play("fade_out")


### ---------------------------------------


### Private Methods -----------------------
### ---------------------------------------


