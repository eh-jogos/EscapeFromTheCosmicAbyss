@tool
class_name MidBossSkin
extends Node2D

## Simple Helper to play animations from inside the skin from AnimationPlayers in JetPackGame scene
## which have to animate the boss through the background.

#region Member Variables and Dependencies ---------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const _PROP_CURRENT_ANIM := "current_animation"

#--- public variables - order: export > normal var > onready --------------------------------------

var current_animation := "idle":
	set(value):
		current_animation = value
		if is_inside_tree():
			_animator.has_animation(current_animation)
			_animator.play(current_animation)

#--- private variables - order: export > normal var > onready -------------------------------------

@export var _animator: AnimationPlayer = null

#endregion Member Variables and Dependencies ------------------------------------------------------


#region Built in Engine Methods -------------------------------------------------------------------

#endregion Built in Engine Methods ----------------------------------------------------------------


#region Public Methods ----------------------------------------------------------------------------

#endregion Public Methods -------------------------------------------------------------------------


#region Private Methods ---------------------------------------------------------------------------

func _validate_property(property: Dictionary) -> void:
	match property.name:
		&"_animator":
			if Engine.is_editor_hint() and not get_tree().edited_scene_root == self:
				# Bitwise ADD flag
				property.usage = property.usage | PROPERTY_USAGE_READ_ONLY
			else:
				# Bitwise REMOVE flag
				property.usage = property.usage & (~PROPERTY_USAGE_READ_ONLY)


func _get_property_list() -> Array[Dictionary]:
	var value: Array[Dictionary] = []
	
	var anim_list := _animator.get_animation_list()
	if anim_list.size() > 0:
		var enum_hint = ",".join(anim_list)
		value.append(
			Utilities.get_property_dict(
				_PROP_CURRENT_ANIM,
				TYPE_STRING_NAME,
				PROPERTY_HINT_ENUM,
				enum_hint
			)
		)
	
	return value


func _property_can_revert(property: StringName) -> bool:
	var value := true if property == _PROP_CURRENT_ANIM else false
	return value


func _property_get_revert(property: StringName) -> Variant:
	const DEFAULT_ANIM = "RESET"
	var value: Variant = null
	
	match property:
		_PROP_CURRENT_ANIM:
			value = DEFAULT_ANIM
	
	return value

#endregion Private Methods ------------------------------------------------------------------------
