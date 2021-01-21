# Write your doc string for this file here
tool
extends ColorRect

### Member Variables and Dependencies -------------------------------------------------------------
#--- signals --------------------------------------------------------------------------------------

#--- enums ----------------------------------------------------------------------------------------

#--- constants ------------------------------------------------------------------------------------

#--- public variables - order: export > normal var > onready --------------------------------------

export(int, 0, 3) var energy: int = 0 setget _set_shield_energy
export var color_in_energy_0: Color = Color("007171ff")
export var color_out_energy_0: Color = Color("007171ff")
export var color_in_energy_1: Color = Color("7171ff")
export var color_out_energy_1: Color = Color("007171ff")
export var color_in_energy_2: Color = Color("44a6ff")
export var color_out_energy_2: Color = Color("7171ff")
export var color_in_energy_3: Color = Color("00f5ff")
export var color_out_energy_3: Color = Color("44a6ff")

#--- private variables - order: export > normal var > onready -------------------------------------

onready var _shader: ShaderMaterial = material as ShaderMaterial
onready var _animator: AnimationPlayer = $AnimationPlayer

### -----------------------------------------------------------------------------------------------


### Built in Engine Methods -----------------------------------------------------------------------

func _ready():
	pass

### -----------------------------------------------------------------------------------------------


### Public Methods --------------------------------------------------------------------------------

### -----------------------------------------------------------------------------------------------


### Private Methods -------------------------------------------------------------------------------

func _set_shield_energy(value: int) -> void:
	energy = value
	
	if not is_inside_tree():
		yield(self, "ready")
	
	_shader.set_shader_param("color_in", get("color_in_energy_%s"%[energy]))
	_shader.set_shader_param("color_out", get("color_out_energy_%s"%[energy]))
	_shader.set_shader_param("has_shield_below", energy > 1)
	if energy > 0:
		_shader.set_shader_param("dissolve_amount", 0.0)
		_animator.play("idle")
	else:
		_shader.set_shader_param("dissolve_amount", 1.0)
		_animator.play("base")

### -----------------------------------------------------------------------------------------------
