# Write your doc string for this file here
extends Control

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

export var buy_game_button_path: NodePath = NodePath("")

#--- private variables - order: export > normal var > onready -------------------------------------

var _button_buy_game: BasicGameButton

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready():
	yield(owner, "ready")
	_button_buy_game = get_node(buy_game_button_path)
	if OS.has_feature("demo") or get_tree().get_current_scene() == owner:
		for index in get_child_count():
			var button: BaseButton = get_child(index)
			button.focus_neighbour_bottom = button.get_path_to(_button_buy_game)
			
			if button.name == "TutorialButton":
				button.focus_neighbour_left = button.get_path_to($LevelButton5)
			elif button.name == "LevelButton5":
				button.focus_neighbour_right = button.get_path_to(_button_buy_game)
				button.focus_neighbour_top = button.get_path_to(_button_buy_game)

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------
