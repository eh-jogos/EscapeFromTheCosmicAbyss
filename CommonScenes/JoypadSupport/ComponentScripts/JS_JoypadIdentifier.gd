extends Node
class_name JS_JoypadIdentifier
# Class to be used as a component of JoypadSupport. It abstracts the logic of Identifying which
# Joypad is connected, and delaing with other related functionality, like setting Joypad Prompts
# skin or setting a fixed one. 
#
# To use it standalone you'll either have to remove the autodetect checks from 
# `_get_joypad_type_for` and `get_joypad_prompt_gallery` methods, or extend this script to 
# override them. You'll also have to detect when a Joypad was plugged in elsewhere, as this is 
# what JoypadSupport autoload is for, and then call the methods in this class from there. 
# For an example check `_set_joypad` on the JoypadSupport autoload and when/how it's called there.

### Member Variables and Dependencies -----
# signals 
# enums
enum JoyPads {
	NO_JOYPAD,
	XBOX,
	PLAYSTATION,
	NINTENDO,
	UNINDENTIFIED,
}

# constants
# export variables
# public variables
var joypad_type: int = JoyPads.NO_JOYPAD

@export var _input_images_ps: PromptGalleryJoypad = null
@export var _input_images_xbox: PromptGalleryJoypad = null
@export var _input_images_nintendo: PromptGalleryJoypad = null

### ---------------------------------------


### Built in Engine Methods ---------------

### ---------------------------------------


### Public Methods ------------------------
func reset_joypad_type():
	joypad_type = JoyPads.NO_JOYPAD


func get_fallback_joypad_gallery() -> PromptGalleryJoypad:
	return _input_images_xbox


func set_joypad_type_for(device: int) -> void:
	var device_name: = Input.get_joy_name(device)
	joypad_type = _get_joypad_type_for(device_name)
	print("device_name: %s | joypad_type: %s"%[device_name, joypad_type])


func get_joypad_prompt_gallery() -> PromptGallery:
	if not JoypadSupport.get_autodetect():
		joypad_type = JoypadSupport.get_chosen_skin()
	
	var joypad_prompts: = _get_prompt_gallery_for(joypad_type)
	return joypad_prompts

### ---------------------------------------


### Private Methods -----------------------
func _get_joypad_type_for(device_name: String) -> int:
	if not JoypadSupport.get_autodetect():
		return JoypadSupport.get_chosen_skin()
	
	return _get_type_for(device_name)


func _get_type_for(device_name: String) -> int:
	var type: int = JoyPads.UNINDENTIFIED
	
	if device_name.find("PS") != -1:
		type = JoyPads.PLAYSTATION
	elif device_name.find("Nintendo") != -1:
		type = JoyPads.NINTENDO
	elif device_name.find("Xbox") != -1 or \
		device_name.find("XBOX") != -1 or \
		device_name.find("X360") != -1:
		type = JoyPads.XBOX
	
	return type


func _get_prompt_gallery_for(type: int) -> PromptGallery:
	var value: PromptGallery = null
	
	match type:
		JoyPads.PLAYSTATION:
			value = _input_images_ps
		JoyPads.NINTENDO:
			value = _input_images_nintendo
		JoyPads.XBOX, JoyPads.UNINDENTIFIED:
			value = _input_images_xbox
		_:
			if joypad_type == JoyPads.NO_JOYPAD:
				push_error("There should be no joypad, what are you doing here? Or if there" \
					+ "is a joypad, what AM I doing here?")
				assert(false)
			else:
				print_debug("unregistered joypad type (%s), defaulting to xbox"%[
					JoyPads.keys()[joypad_type]])
			value = _input_images_xbox
	
	return value

### ---------------------------------------
