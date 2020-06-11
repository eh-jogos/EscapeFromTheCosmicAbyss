extends "res://JetpackGameMode/Obstacles/Pipe_Looper.gd"
# Write your doc striing for this file here

### Member Variables and Dependencies -----
# signals 
# enums
# constants
# public variables - order: export > normal var > onready 
# private variables - order: export > normal var > onready 
### ---------------------------------------


### Built in Engine Methods ---------------
func _ready():
	pass

### ---------------------------------------


### Public Methods ------------------------
func scored():
	game._on_scored(point_value)
	Global.achievements_handler.current_barriers += 1

### ---------------------------------------


### Private Methods -----------------------

### ---------------------------------------
