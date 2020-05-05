extends Label


var messages = {
	"accelerating": "ACCELERATING...",
	"max_speed": "MAX SPEED REACHED!",
	"max_speed_increased": "MAX SPEED INCREASED!",
}

var animator


func _ready():
	animator = get_node("Messager")


func play():
	animator.play("text_anim")


func play_accelerating_message():
	if animator.is_playing():
		return
	
	self.text = messages["accelerating"]
	play()


func play_max_speed_message():
	if animator.is_playing():
		return
	
	self.text = messages["max_speed"]
	play()


func play_max_speed_increased_message():
	if animator.is_playing():
		return
	
	self.text = messages["max_speed_increased"]
	play()
