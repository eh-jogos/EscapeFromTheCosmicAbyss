extends Label

var run_time = 0

func _on_Timer_timeout():
	run_time += 1
	print_time(run_time)


func print_time(runtime):
	var minutes = int(runtime/60)
	var seconds = int(runtime%60)
	
	self.set_text("%02d:%02d"%[minutes,seconds])
