class_name AchievementObject
extends TextureRect
# Write your doc striing for this file here

### Member Variables and Dependencies -----
# signals 
# enums
enum Type {
	FLAG,
	PROGRESS
}
# constants
# public variables - order: export > normal var > onready 
# private variables - order: export > normal var > onready
export var _title : = "" 
export var _description : = ""
export var _unachieved : Texture = null
export var _achieved : Texture = null
export(Type) var _type : = Type.FLAG
export var _achievement_variable : = ""

onready var _hightlight_panel = $Panel
### ---------------------------------------


### Built in Engine Methods ---------------
func _ready():
	connect("focus_entered", self, "_on_focus_entered")
	connect("focus_exited", self, "_on_focus_exited")
	connect("mouse_entered", self, "_on_mouse_entered")
	_update_appearence()
	_hightlight_panel.hide()

### ---------------------------------------


### Public Methods ------------------------

### ---------------------------------------


### Private Methods -----------------------
func _on_focus_entered() -> void:
	Global.emit_signal("achievement_info_sent", _title, _description)
	_hightlight_panel.show()


func _on_focus_exited() -> void:
	_hightlight_panel.hide()
	SoundManager.play_sfx("Select")


func _on_mouse_entered() -> void:
	grab_focus()


func _update_appearence() -> void:
	var has_achieved: = false
	match _type:
		Type.FLAG:
			has_achieved = Global.achievements_handler.get(_achievement_variable)
		Type.PROGRESS:
			has_achieved = Global.achievements_handler.call(_achievement_variable)
	
	if has_achieved:
		texture = _achieved
	else:
		texture = _unachieved
### ---------------------------------------
