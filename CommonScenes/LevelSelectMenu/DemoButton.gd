# Write your doc string for this file here
extends BasicGameButton

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

export var _prompt_path: NodePath = NodePath(".")

onready var _prompt: BaseLegend = get_node(_prompt_path) as BaseLegend

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready():
	if OS.has_feature("demo") or get_tree().get_current_scene() == owner:
		show()
		disabled = false
	else:
		hide()
		disabled = true
	
	yield(owner, "ready")
	focus_neighbour_top = get_path_to(owner.initial_btn)


func _pressed() -> void:
	var buy_screen_path = "res://CommonScenes/DemoThankYou/DemoThankYou.tscn"
	ScreenManager.black_transition(buy_screen_path, self, owner, false)
	_prompt.fade_out()

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
