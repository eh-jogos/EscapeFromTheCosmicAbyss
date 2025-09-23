extends Node

@export var position_range: NodePath
@export var shield_icon: NodePath
@export var shield_increment: int

@onready var _position_range = get_node(position_range)
@onready var _shield_icon = get_node(shield_icon)

func _ready():
	var random_position = randf_range(0.0,1.0)
	_position_range.set_progress_ratio(random_position)

func _on_VisibilityNotifier2D_exit_screen():
	#print("Kill")
	get_parent().queue_free()


func _on_ShieldIcon_body_enter( body ):
	if body.is_in_group("player"):
		body.shield_up(shield_increment)
		_shield_icon.queue_free()
