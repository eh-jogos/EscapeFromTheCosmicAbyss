@tool
class_name SharedVector2
extends Resource

## A simple resource to create a Vector2 that can be passed as "shared" and used in multiple
## places in sync.

#region Member Variables and Dependencies ---------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#TODO move possible features to a base "SharedData" class
# I think it would be this boolean itself, the reset function and while I can't move `_validade_`
# to a base class because I can't have `value` and `default_value` there, I can at least move the
# PROPERTY_USAGE_* logic to there.
@export var reset_on_runtime := true:
	set(p_value):
		reset_on_runtime = p_value
		notify_property_list_changed()

@export var value: Vector2 = Vector2.ZERO:
	set(p_value):
		var has_changed := value != p_value
		value = p_value
		if has_changed:
			emit_changed()

@export var default_value: Vector2 = Vector2.ZERO

#--- private variables - order: export > normal var > onready -------------------------------------

#endregion Member Variables and Dependencies ------------------------------------------------------


#region Built in Engine Methods -------------------------------------------------------------------

func _init() -> void:
	if reset_on_runtime:
		reset_value()


func _validate_property(property: Dictionary) -> void:
	match property.name:
		&"value":
			if reset_on_runtime:
				# Bitwise ADD flag
				property.usage = PROPERTY_USAGE_STORAGE
			else:
				# Bitwise REMOVE flag
				property.usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE

#endregion Built in Engine Methods ----------------------------------------------------------------


#region Public Methods ----------------------------------------------------------------------------

func reset_value() -> void:
	value = default_value

#endregion Public Methods -------------------------------------------------------------------------


#region Private Methods ---------------------------------------------------------------------------

#endregion Private Methods ------------------------------------------------------------------------
