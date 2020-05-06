extends ColorRect
# Simple Script to change colors of Laser Core for the boss, in real time

### Member Variables and Dependencies -----
# signals 
# enums
# constants
# export variables
# public variables
# private variables
# onready variables
### ---------------------------------------


### Built in Engine Methods ---------------

func _ready():
	add_to_group("interactive_color")
	colors_changed()

### ---------------------------------------


### Public Methods ------------------------

func colors_changed():
	color = Global.savedata.colors.final_boss.laser_core

### ---------------------------------------


### Private Methods -----------------------
### ---------------------------------------


