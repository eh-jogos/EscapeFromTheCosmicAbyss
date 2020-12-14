tool
extends ViewportContainer

export var blur_amount: float = 1.0 setget _set_blur_amount

onready var blur_y_shader: ShaderMaterial = material as ShaderMaterial
onready var blur_x: ViewportContainer = $Viewport/BlurX
onready var blur_x_shader: ShaderMaterial = blur_x.material as ShaderMaterial

func _set_blur_amount(value: float) -> void:
	blur_amount = value
	
	if not is_inside_tree():
		yield(self, "ready")
	
	blur_y_shader.set_shader_param("blur_scale", Vector2(0, blur_amount))
	blur_x_shader.set_shader_param("blur_scale", Vector2(blur_amount, 0))
