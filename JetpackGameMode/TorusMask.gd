tool
extends ColorRect

var shader: ShaderMaterial = material as ShaderMaterial


func _on_ShockwaveGuide_position_changed(relative_position: Vector2):
	shader.set_shader_param("torus_center", relative_position)
