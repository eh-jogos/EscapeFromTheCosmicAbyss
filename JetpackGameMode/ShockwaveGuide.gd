tool
extends Position2D


signal position_changed(relative_position)

var _old_position: Vector2


func _ready():
	var relative_position = get_relative_position(position)
	emit_signal("position_changed", relative_position)
	
	if not Engine.editor_hint:
		hide()


func _draw():
	draw_circle(Vector2.ZERO, 25, Color.white)


func _process(_delta):
	if position != _old_position:
		var relative_position = get_relative_position(position)
		emit_signal("position_changed", relative_position)
	
	_old_position = position


func get_relative_position(pixel_position: Vector2) -> Vector2:
	var relative_position: = Vector2.ZERO
	relative_position = pixel_position / get_viewport_rect().size
	return relative_position
