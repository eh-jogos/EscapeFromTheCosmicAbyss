class_name Utilities
extends RefCounted

## Helper to where we declare useful static functions that can be used from anywhere


#region Array Helpers -----------------------------------------------------------------------------

static func sum_array(p_total: int, p_current: int) -> int:
	return p_total + p_current


static func capitalize_array(p_element: String) -> String:
	return p_element.capitalize()


static func is_not_null(p_element: Variant) -> bool:
	return p_element != null

#endregion Array Helpers --------------------------------------------------------------------------


#region Advanced Custom Inspectors ----------------------------------------------------------------

static func get_property_dict(
		p_name: String, 
		p_type: Variant.Type,
		p_hint: int = PROPERTY_HINT_NONE,
		p_hint_string: String  = "",
		p_class_name: String = "",
		p_usage: int = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE
) -> Dictionary:
	var value := {
		"name": p_name,
		"class_name": p_class_name,
		"type": p_type,
		"hint": p_hint,
		"hint_string": p_hint_string,
		"usage": p_usage,
	}
	return value


static func get_category_dict(p_name: String) -> Dictionary:
	var value := get_property_dict(
			p_name, TYPE_NIL, PROPERTY_HINT_NONE, "", "", PROPERTY_USAGE_CATEGORY
	)
	return value


static func get_group_dict(p_name: String, hint_string: String = "") -> Dictionary:
	var value := get_property_dict(
			p_name, TYPE_NIL, PROPERTY_HINT_NONE, hint_string, "", PROPERTY_USAGE_GROUP
	)
	return value

#endregion Advanced Custom Inspectors -------------------------------------------------------------
