class_name PromptGalleryJoypad
extends Resource

enum ExtraPrompts {
	DPAD_NEUTRAL,
	LEFT_STICK_UP,
	LEFT_STICK_RIGHT,
	LEFT_STICK_DOWN,
	LEFT_STICK_LEFT,
	RIGHT_STICK_UP,
	RIGHT_STICK_RIGHT,
	RIGHT_STICK_DOWN,
	RIGHT_STICK_LEFT,
}

@export_group("Face Buttons", "_face_button_")
@export var _face_button_a: Texture2D = null
@export var _face_button_b: Texture2D = null
@export var _face_button_x: Texture2D = null
@export var _face_button_y: Texture2D = null
@export var _face_button_dpad_up: Texture2D = null
@export var _face_button_dpad_right: Texture2D = null
@export var _face_button_dpad_down: Texture2D = null
@export var _face_button_dpad_left: Texture2D = null
## PS4 Share (Select), Xbox Back, Nintendo -
@export var _face_button_back: Texture2D = null
## Sony PS, Xbox Home
@export var _face_button_guide: Texture2D = null
@export var _face_button_start: Texture2D = null
@export var _face_button_touchpad: Texture2D = null

@export_group("Shoulder Buttons", "_shoulder_")
@export var _shoulder_button_left: Texture2D = null
@export var _shoulder_trigger_left: Texture2D = null
@export var _shoulder_button_right: Texture2D = null
@export var _shoulder_trigger_right: Texture2D = null

@export_group("Analog Stickes", "_analog_")
@export var _analog_button_left: Texture2D = null
@export var _analog_button_right: Texture2D = null
@export var _analog_left_stick_up: Texture2D = null
@export var _analog_left_stick_right: Texture2D = null
@export var _analog_left_stick_down: Texture2D = null
@export var _analog_left_stick_left: Texture2D = null
@export var _analog_right_stick_up: Texture2D = null
@export var _analog_right_stick_right: Texture2D = null
@export var _analog_right_stick_down: Texture2D = null
@export var _analog_right_stick_left: Texture2D = null

@export_group("Extras", "_extra_")
@export var _extra_dpad: Texture2D = null


var JOY_AXIS_MAP: Dictionary[int, Texture2D] = {
	JOY_AXIS_LEFT_X = Texture2D.new(),
	JOY_AXIS_LEFT_Y = Texture2D.new(),
	JOY_AXIS_RIGHT_X = Texture2D.new(),
	JOY_AXIS_RIGHT_Y = Texture2D.new(),
	JOY_AXIS_TRIGGER_LEFT = Texture2D.new(),
	JOY_AXIS_TRIGGER_RIGHT = Texture2D.new(),
}


func get_button_texture_for(joypad_code: int) -> Texture2D:
	var value: Texture2D
	match joypad_code:
		JOY_BUTTON_A:
			value = _face_button_a
		JOY_BUTTON_B:
			value = _face_button_b
		JOY_BUTTON_X:
			value = _face_button_x
		JOY_BUTTON_Y:
			value = _face_button_y
		JOY_BUTTON_BACK:
			value = _face_button_back
		JOY_BUTTON_START:
			value = _face_button_start
		JOY_BUTTON_GUIDE:
			value = _face_button_guide
		JOY_BUTTON_LEFT_STICK:
			value = _analog_button_left
		JOY_BUTTON_RIGHT_STICK:
			value = _analog_button_right
		JOY_BUTTON_LEFT_SHOULDER:
			value = _shoulder_button_left
		JOY_BUTTON_RIGHT_SHOULDER:
			value = _shoulder_button_right
		JOY_BUTTON_DPAD_UP:
			value = _face_button_dpad_up
		JOY_BUTTON_DPAD_RIGHT:
			value = _face_button_dpad_right
		JOY_BUTTON_DPAD_DOWN:
			value = _face_button_dpad_down
		JOY_BUTTON_DPAD_LEFT:
			value = _face_button_dpad_left
		JOY_BUTTON_TOUCHPAD:
			value = _face_button_touchpad
		_:
			push_error("Unindentfied JOY_BUTTON_ constant: %s"%[joypad_code])
	return value


func get_axis_texture_for(axis_event: InputEventJoypadMotion) -> Texture2D:
	var value: Texture2D = null
	var direction: int = signi(axis_event.axis_value)
	match axis_event.axis:
		JOY_AXIS_LEFT_X:
			if direction == 1:
				value = _analog_left_stick_right
			elif direction == -1:
				value = _analog_left_stick_left
			else:
				value = _analog_button_left
		JOY_AXIS_LEFT_Y:
			if direction == 1:
				value = _analog_left_stick_down
			elif direction == -1:
				value = _analog_left_stick_up
			else:
				value = _analog_button_left
		JOY_AXIS_RIGHT_X:
			if direction == 1:
				value = _analog_right_stick_right
			elif direction == -1:
				value = _analog_right_stick_left
			else:
				value = _analog_button_right
		JOY_AXIS_RIGHT_Y:
			if direction == 1:
				value = _analog_right_stick_down
			elif direction == -1:
				value = _analog_right_stick_up
			else:
				value = _analog_button_right
		JOY_AXIS_TRIGGER_LEFT:
			value = _shoulder_trigger_left
		JOY_AXIS_TRIGGER_RIGHT:
			value = _shoulder_trigger_right
		_:
			push_error("Unindentfied JOY_AXIS_ constant: %s"%[axis_event.axis])
	return value


func get_extra_texture_for(extra_code: ExtraPrompts) -> Texture2D:
	var value: Texture2D = null
	match extra_code:
		ExtraPrompts.DPAD_NEUTRAL:
			value = _extra_dpad
		ExtraPrompts.LEFT_STICK_UP:
			value = _analog_left_stick_up
		ExtraPrompts.LEFT_STICK_RIGHT:
			value = _analog_left_stick_right
		ExtraPrompts.LEFT_STICK_DOWN:
			value = _analog_left_stick_down
		ExtraPrompts.LEFT_STICK_LEFT:
			value = _analog_left_stick_left
		ExtraPrompts.RIGHT_STICK_UP:
			value = _analog_right_stick_up
		ExtraPrompts.RIGHT_STICK_RIGHT:
			value = _analog_right_stick_right
		ExtraPrompts.RIGHT_STICK_DOWN:
			value = _analog_right_stick_down
		ExtraPrompts.RIGHT_STICK_LEFT:
			value = _analog_right_stick_left
		_:
			push_error("Unindentfied ExtraPrompt enum value: %s"%[extra_code])
	return value
	
