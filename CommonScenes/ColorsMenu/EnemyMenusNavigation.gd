extends Control

export(int) var current_menu = 0 setget _set_current_menu

onready var container_menus = get_node("EnemyMenus")
onready var tween = get_node("Tween")

# fix for using Global on tool
var Global = null

func _ready():
	set_process_input(false)
	self.current_menu = current_menu
	
	if not Engine.editor_hint:
		Global = get_node("/root/Global")
		Global.connect("navigated_to_right", self, "_on_Global_navigated_to_right")
		Global.connect("navigated_to_left", self, "_on_Global_navigated_to_left")


func _input(event):
	if event.is_action_pressed("ui_right"):
		self.current_menu += 1
	elif event.is_action_pressed("ui_left"):
		self.current_menu -= 1 


func _set_current_menu(value):
	if container_menus == null:
		return
	
	var previous_menu_node = container_menus.get_child(current_menu)
	current_menu = clamp(value, 0, container_menus.get_child_count()-1)
	var menu_node = container_menus.get_child(current_menu)
	var menu_position = menu_node.rect_position
	menu_position.x *= -1
	
	tween.remove_all()
	tween.interpolate_property(container_menus, "rect_position", 
			container_menus.rect_position, menu_position, 0.3, 
			Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()
	
	if not Engine.editor_hint:
		previous_menu_node.deactivate()
		menu_node.activate()


func _on_ArrowRight_pressed():
	self.current_menu += 1


func _on_ArrowLeft_pressed():
	self.current_menu -= 1


func _on_Global_navigated_to_right():
	self.current_menu += 1


func _on_Global_navigated_to_left():
	self.current_menu -= 1
