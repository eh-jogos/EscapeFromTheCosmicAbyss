extends EditorInspectorPlugin

const PATH_PREFIX = "call_method_"

var button_scene = preload("res://addons/eh_jogos.export_button/ui/inspector_button.tscn")

func can_handle(object):
	return true

func parse_property(object, type, path, hint, hint_text, usage):
	var should_handle: = false
	if type == TYPE_DICTIONARY:
		if path.find(InspectorButtonWidget.PATH_PREFIX) != -1:
			var button = button_scene.instance()
			add_custom_control(button)
			button.object = object
			var prefix_size = PATH_PREFIX.length()
			var method_name = path.substr(prefix_size, path.length() - prefix_size)
			button.method = method_name
			
			var data_dict = object.get(path)
			if data_dict.has("text"):
				button.text = data_dict.text
			
			should_handle = false
	
	return should_handle
