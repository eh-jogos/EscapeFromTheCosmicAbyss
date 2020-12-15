tool
extends TextureRect

var shader: ShaderMaterial = material as ShaderMaterial


func _on_ShockwaveGuide_position_changed(relative_position: Vector2):
	shader.set_shader_param("displacement_center", relative_position)
