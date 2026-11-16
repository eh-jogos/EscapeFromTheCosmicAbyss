@tool
extends eh_Shaker2D

var _shaky_camera: Camera2D

var _decay_backup: float = 0.0

@onready var _main_camera: Camera2D = get_parent()

func _ready() -> void:
	super()
	_decay_backup = decay
	_shaky_camera = _target as Camera2D
	trauma_ended.connect(_on_trauma_ended)
	trauma_started.connect(_on_trauma_started)
	Global.continuous_shake_started.connect(_on_continuous_shake_started)
	Global.continuous_shake_ended.connect(_on_continuous_shake_ended)


#region Private Methods ---------------------------------------------------------------------------

func _on_trauma_started() -> void:
	if not _shaky_camera.is_current():
		_shaky_camera.make_current()
		_main_camera.position_smoothing_enabled = false


func _on_trauma_ended() -> void:
	_main_camera.make_current()
	_main_camera.position_smoothing_enabled = true


func _on_continuous_shake_started(p_trauma: float) -> void:
	if not decay == 0.0:
		decay = 0.0
		add_trauma(p_trauma)


func _on_continuous_shake_ended() -> void:
	if decay == 0.0:
		decay = _decay_backup

#endregion Private Methods ------------------------------------------------------------------------

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
