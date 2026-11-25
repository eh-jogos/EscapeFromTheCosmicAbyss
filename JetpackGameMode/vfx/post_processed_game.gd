extends TextureRect

## Write your doc string for this file here

#region Member Variables and Dependencies ---------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

#--- private variables - order: export > normal var > onready -------------------------------------

@export var _scream_center: SharedVector2 = null

var _shader: ShaderMaterial = null

#endregion Member Variables and Dependencies ------------------------------------------------------


#region Built in Engine Methods -------------------------------------------------------------------

func _ready() -> void:
	_shader = material as ShaderMaterial


func _process(_delta: float) -> void:
	_shader.set_shader_parameter("displacement_center", _scream_center.value)

#endregion Built in Engine Methods ----------------------------------------------------------------


#region Public Methods ----------------------------------------------------------------------------

#endregion Public Methods -------------------------------------------------------------------------


#region Private Methods ---------------------------------------------------------------------------

#endregion Private Methods ------------------------------------------------------------------------
