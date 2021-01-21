tool
extends Button
class_name InspectorButton
# Write your doc striing for this file here

### Member Variables and Dependencies -----
# signals 
# enums
# constants
# public variables - order: export > normal var > onready 

var object: Object = null
var method: String = ""
var arguments: Array = []

# private variables - order: export > normal var > onready 
### ---------------------------------------


### Built in Engine Methods ---------------
func _ready():
	pass

func _pressed():
	if object != null and method != "":
		var param_name: = "call_method_%s"%[method]
		var config_dict: Dictionary = object.get(param_name)
		if config_dict.has("arguments"):
			arguments = config_dict.arguments
			print("object: %s | member: %s | value: %s"%[object, param_name, config_dict])
		object.callv(method, arguments)

### ---------------------------------------


### Public Methods ------------------------
### ---------------------------------------


### Private Methods -----------------------
### ---------------------------------------


