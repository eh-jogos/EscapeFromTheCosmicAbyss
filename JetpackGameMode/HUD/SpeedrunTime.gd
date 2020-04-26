extends Label

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var run_time = 0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func _on_Timer_timeout():
	run_time += 1
	print_time(run_time)

func print_time(runtime):
	var minutes = int(runtime/60)
	var seconds = int(runtime%60)
	
	if minutes < 10:
		minutes = "0%s"%[minutes]
	
	if seconds < 10:
		seconds = "0%s"%[seconds]
	
	self.set_text("%s:%s"%[minutes,seconds])
