extends Node
# Class to handle mouse pointer primarily for games that do not use mouse pointer in gameplay
# but want to make it available to interact with menus and UI in general.
# The default behavior is to Hide the mouse when it's not being moved and show it when it is.
# You can use export vars to configure which mouse modes do you want for the active mouse and for
# the inactive mouse, and can set the delay to hide the mouse once it becomes inactive by setting
# the wait time on the timer.

### Member Variables and Dependencies -----
# signals 
# enums
enum MouseModes {
	VISIBLE = Input.MOUSE_MODE_VISIBLE,
	HIDDEN = Input.MOUSE_MODE_HIDDEN,
	CONFINED = Input.MOUSE_MODE_CONFINED,
	CAPTURED = Input.MOUSE_MODE_CAPTURED
}
# constants
# public variables - order: export > normal var > onready 
export(MouseModes) var active_mouse_mode: = Input.MOUSE_MODE_VISIBLE setget set_active_mouse_mode
export(MouseModes) var inactive_mouse_mode: = Input.MOUSE_MODE_CAPTURED setget set_inactive_mouse_mode

# private variables - order: export > normal var > onready
export var _should_log: = false
onready var _timer: Timer = $MousePointerTimer
### ---------------------------------------


### Built in Engine Methods ---------------
func _notification(what: int) -> void:
	match what: 
		MainLoop.NOTIFICATION_WM_MOUSE_EXIT:
			if _should_log:
				print("Mouse OUT!")
			set_process_input(false)
			if not _timer.is_stopped():
				_timer.stop()
		MainLoop.NOTIFICATION_WM_MOUSE_ENTER:
			if _should_log:
				print("Mouse IN!")
			set_process_input(true)


func _input(event):
	_handle_mouse_pointer(event)

### ---------------------------------------


### Public Methods ------------------------

func set_active_mouse_mode(value: int) -> void:
	if is_valid_mouse_moude(value):
		active_mouse_mode = value
	else:
		push_invalid_mouse_mode_error(value)


func set_inactive_mouse_mode(value: int) -> void:
	if is_valid_mouse_moude(value):
		inactive_mouse_mode = value
	else:
		push_invalid_mouse_mode_error(value)

### ---------------------------------------


### Private Methods -----------------------
func _handle_mouse_pointer(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if _should_log:
			print("Mouse Motion")
		
		Input.set_mouse_mode(active_mouse_mode)
		_timer.start()
	else:
		if _should_log:
			print("Not Mouse Motion")
		
		if Input.get_mouse_mode() != inactive_mouse_mode:
			if _timer.is_stopped():
				_timer.start()


func _on_MousePointerTimer_timeout():
	if _should_log:
		print("Mouse Pointer Time Out!")
	Input.set_mouse_mode(inactive_mouse_mode)


func is_valid_mouse_moude(value: int) -> bool:
	return value == MouseModes.CAPTURED or value == MouseModes.CONFINED \
			or value == MouseModes.HIDDEN or value == MouseModes.VISIBLE


func push_invalid_mouse_mode_error(value: int) -> void:
	push_error("Invalid mouse mode: %s | It must be one of: %s %s %s %s"%[
				value,
				MouseModes.CAPTURED,
				MouseModes.CONFINED,
				MouseModes.HIDDEN,
				MouseModes.VISIBLE
		])
	assert(false)

### ---------------------------------------
