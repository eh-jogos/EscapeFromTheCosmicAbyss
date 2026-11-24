@tool
class_name ScreamPositionHelper
extends Marker2D

## This node serves as a visual guide that can be animated from inside any scene, and will 
## automatically animate the relevant shader parameters on the correct ShaderMaterials
## which will reflect on the visual FXs animating correctly.
## 
## The [member wave1_radius] and [member wave2_radius] can be animated directly, but for the 
## position to be forwarded to the materials this nodes processing must be enabled. [br]
## [br]
## Ideal use case is to use [AnimationPlayer] and use a method track to enable and disable 
## process accordingly.

#region Member Variables and Dependencies ---------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

const _PARAM_RADIUS = "torus_radius"
const _PARAM_THICKNESS = "torus_thickness"
const _PARAM_HARDNESS = "torus_hardness"

#--- public variables - order: export > normal var > onready --------------------------------------

@export_group("Scream Wave 1", "wave1_")
## Radius for first torus of scream shockwave effect.
@export_range(-0.1,3.0,0.01) var wave1_radius: float = -0.1:
	set(value):
		wave1_radius = value
		_update_shader_param(_shockwave1, _PARAM_RADIUS, value)
@export_range(0.001,1.0,0.001) var wave1_thickness: float = 0.5:
	set(value):
		wave1_thickness = value
		_update_shader_param(_shockwave1, _PARAM_THICKNESS, value)
@export_range(0.0,8.0,0.001) var wave1_hardness: float = 1.0:
	set(value):
		wave1_hardness = value
		_update_shader_param(_shockwave1, _PARAM_HARDNESS, value)

@export_group("Scream Wave 2", "wave2_")
## Radius for second torus of scream shockwave effect.
@export_range(-0.1,3.0,0.01) var wave2_radius: float = -0.1:
	set(value):
		wave2_radius = value
		_update_shader_param(_shockwave2, _PARAM_RADIUS, value)
@export_range(0.001,1.0,0.001) var wave2_thickness: float = 0.5:
	set(value):
		wave2_thickness = value
		_update_shader_param(_shockwave2, _PARAM_THICKNESS, value)
@export_range(0.0,8.0,0.001) var wave2_hardness: float = 1.0:
	set(value):
		wave2_hardness = value
		_update_shader_param(_shockwave2, _PARAM_HARDNESS, value)

#--- private variables - order: export > normal var > onready -------------------------------------

## [ShaderMaterial] responsible for first torus of scream shockwave effect.
@export var _shockwave1: ShaderMaterial = null
## [ShaderMaterial] responsible for second torus of scream shockwave effect.
@export var _shockwave2: ShaderMaterial = null
## [ShaderMaterial] responsible for distortion effect layering the torus mask on top of the 
## game's post processing layer.
@export var _displacement_vfx: ShaderMaterial = null

var _materials: Array[Resource] = []

#endregion Member Variables and Dependencies ------------------------------------------------------


#region Built in Engine Methods -------------------------------------------------------------------

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	set_process(false)
	_materials = [_shockwave1, _shockwave2, _displacement_vfx]


func _process(_delta: float) -> void:
	const PARAM_TORUS := "torus_center"
	const PARAM_VFX := "displacement_center"
	if Engine.is_editor_hint():
		return
	
	if not _materials.is_empty() and _materials.all(Utilities.is_not_null):
		var relative_position := _get_screen_relative_position()
		_shockwave1.set_shader_parameter(PARAM_TORUS, relative_position)
		_shockwave2.set_shader_parameter(PARAM_TORUS, relative_position)
		_displacement_vfx.set_shader_parameter(PARAM_VFX, relative_position)


func _draw():
	if Engine.is_editor_hint():
		draw_circle(Vector2.ZERO, 15.0, Color.WHITE)
		var viewport_size := get_viewport_rect().size
		if wave1_radius > 0.0:
			draw_circle(
					Vector2.ZERO, 
					wave1_radius * viewport_size.x, 
					Color.FIREBRICK, 
					false, 
					wave1_thickness * viewport_size.x
			)
		
		if wave2_radius > 0.0:
			draw_circle(
					Vector2.ZERO, 
					wave2_radius * viewport_size.x, 
					Color.REBECCA_PURPLE, 
					false, 
					wave2_thickness * viewport_size.x
			)

#endregion Built in Engine Methods ----------------------------------------------------------------


#region Public Methods ----------------------------------------------------------------------------

#endregion Public Methods -------------------------------------------------------------------------


#region Private Methods ---------------------------------------------------------------------------

func _update_shader_param(p_material: ShaderMaterial, p_param: String, p_value: Variant) -> void:
	if Engine.is_editor_hint():
		queue_redraw()
	elif is_inside_tree() and p_material != null:
		p_material.set_shader_parameter(p_param, p_value)


func _get_screen_relative_position() -> Vector2:
	var screen_position := get_global_transform_with_canvas().origin
	var value := screen_position / get_viewport_rect().size
	return value

#endregion Private Methods ------------------------------------------------------------------------
