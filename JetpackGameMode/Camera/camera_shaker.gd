@tool
extends eh_Shaker2D

var _shaky_camera: Camera2D

func _ready() -> void:
	super()
	_shaky_camera = _target as Camera2D
	trauma_ended.connect(_on_trauma_ended)
	trauma_started.connect(_on_trauma_started)


func _on_trauma_started() -> void:
	if not _shaky_camera.is_current():
		_shaky_camera.enabled = true
		_shaky_camera.make_current()


func _on_trauma_ended() -> void:
	_shaky_camera.enabled = false


#region eh_Shaker2D overrides ---------------------------------------------------------------------

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

#endregion eh_Shaker2D overrides ------------------------------------------------------------------
