extends RayCast2D

# class member variables go here, for example:
var animator
var idle_timer
var idle_duration
var parent

signal laser_end

func _ready():
	#print("Bullet Ready")
	animator = self.get_node("AnimationPlayer")
	animator.play("fire")
	
	idle_timer = self.get_node("IdleTimer")
	
	set_fixed_process(true)
	pass

func set_laser_duration(duration):
	idle_duration = duration - 0.3 - 0.5

func _fixed_process(delta):
	if self.is_colliding():
		var collider = self.get_collider()
		#print(collider.get_name())
		if collider.is_in_group("pipes"):
			print("Bullet HIT")
			collider.emit_signal("die")


func start_idle_timer():
	#print("Bullet Idle")
	animator.play("idle")
	idle_timer.set_wait_time(idle_duration)
	idle_timer.start()

func _on_idle_timeout():
	animator.play("fadeout")
	yield(animator, "finished")
	emit_signal("laser_end")
	#print("Bullet Fade")
	self.queue_free()
