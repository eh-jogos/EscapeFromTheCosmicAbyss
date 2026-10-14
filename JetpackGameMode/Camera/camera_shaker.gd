@tool
extends eh_Shaker2D

func _update_base_values() -> void:
	if _target is Camera2D:
		if _target.offset != base_offset:
			base_offset = _target.offset
		
		if _target.rotation != base_rotation:
			base_rotation = _target.rotation
	else:
		super._update_base_values()


func _apply_shake(p_rotation: float, p_position: Vector2) -> void:
	if _target is Camera2D:
		_target.rotation = p_rotation
		_target.offset = p_position
	else:
		super._apply_shake(p_rotation, p_position)
