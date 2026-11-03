class_name Utilities
extends RefCounted

## Helper to where we declare useful static functions that can be used from anywhere


#region Array Helpers -----------------------------------------------------------------------------

static func sum_array(p_total: int, p_current: int) -> int:
	return p_total + p_current


static func capitalize_array(p_element: String) -> String:
	return p_element.capitalize()

#endregion Array Helpers --------------------------------------------------------------------------
