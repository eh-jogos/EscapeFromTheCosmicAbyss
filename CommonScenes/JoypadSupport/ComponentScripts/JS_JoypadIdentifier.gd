tool
extends Node
class_name JS_JoypadIdentifier
# Class to be used as a component of JoypadSupport. It abstracts the logic of Identifying which
# Joypad is connected, and delaing with other related functionality, like setting Joypad Prompts
# skin or setting a fixed one.

### Member Variables and Dependencies -----
# signals 
# enums
# constants
# export variables
# public variables
# private variables
var _should_autodetect_joypad_skin: = true

onready var _chosen_skin = JoypadSupport.JoyPads.UNINDENTIFIED

onready var _prompts_ps: ResourcePreloader = owner.get_node("Playstation")
onready var _prompts_xbox: ResourcePreloader = owner.get_node("Xbox")
onready var _prompts_nintendo: ResourcePreloader = owner.get_node("Nintendo")

### ---------------------------------------


### Built in Engine Methods ---------------

### ---------------------------------------


### Public Methods ------------------------
func get_joypad_type(device_name: String) -> int:
	if not _should_autodetect_joypad_skin:
		return _chosen_skin
	
	var type: = _get_type_for(device_name)
	return type


func get_joypad_prompts() -> ResourcePreloader:
	var joypad_type = JoypadSupport.joypad_type
	if not _should_autodetect_joypad_skin:
		joypad_type = _chosen_skin
	
	var joypad_prompts: = _get_prompt_for(joypad_type)
	return joypad_prompts

### ---------------------------------------


### Private Methods -----------------------
func _get_type_for(device_name: String) -> int:
	var type: int = JoypadSupport.JoyPads.UNINDENTIFIED
	
	if device_name.find("PS") != -1:
		type = JoypadSupport.JoyPads.PLAYSTATION
	elif device_name.find("Nintendo") != -1 or device_name.find("Steam") != -1:
		type = JoypadSupport.JoyPads.NINTENDO
	elif device_name.find("Xbox") != -1 or \
		device_name.find("XBOX") != -1 or \
		device_name.find("X360") != -1:
		type = JoypadSupport.JoyPads.XBOX
	
	return type


func _get_prompt_for(type: int) -> ResourcePreloader:
	var joypad_prompts: ResourcePreloader = null
	
	match type:
		JoypadSupport.JoyPads.PLAYSTATION:
			joypad_prompts = _prompts_ps
		JoypadSupport.JoyPads.NINTENDO:
			joypad_prompts = _prompts_nintendo
		JoypadSupport.JoyPads.XBOX, JoypadSupport.JoyPads.UNINDENTIFIED:
			joypad_prompts = _prompts_xbox
		_:
			if JoypadSupport.joypad_type == JoypadSupport.JoyPads.NO_JOYPAD:
				push_error("There should be no joypad, what are you doing here? Or if there" \
					+ "is a joypad, what AM I doing here?")
				assert(false)
			else:
				print_debug("unregistered joypad type (%s), defaulting to xbox"%[
					JoypadSupport.JoyPads.keys()[JoypadSupport.joypad_type]])
			joypad_prompts = _prompts_xbox
	
	return joypad_prompts


func _set_autodetect_to(on_off: bool) -> void:
	_should_autodetect_joypad_skin = on_off


func _get_autodetect() -> bool:
	return _should_autodetect_joypad_skin


func _set_chosen_skin(skin: int) -> void:
	_chosen_skin = skin


func _get_chosen_skin() -> int:
	return _chosen_skin

### ---------------------------------------


