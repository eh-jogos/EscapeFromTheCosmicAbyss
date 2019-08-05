extends Node2D

# class member variables go here, for example:
var raycast_top
var raycast_bottom
var raycasts

var animator
var idle_timer
var idle_duration
var parent

signal laser_end

func _ready():
	#print("Bullet Ready")
	raycast_top = get_node("TopRaycast")
	raycast_bottom = get_node("BottomRaycast")
	raycasts = [raycast_top, raycast_bottom]
	
	animator = self.get_node("AnimationPlayer")
	animator.play("fire")
	
	idle_timer = self.get_node("IdleTimer")
	
	set_fixed_process(true)


func set_laser_duration(duration):
	var new_height = Vector2(1,1)
	new_height.y += duration
	
	idle_duration = duration - 0.3 - 0.5
	self.set_scale(new_height)


func _fixed_process(delta):
	for raycast in raycasts:
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			#print(collider.get_name())
			if collider.is_in_group("pipes"):
				#print("Bullet HIT")
				collider.emit_signal("die")


func start_idle_timer():
	#print("Bullet Idle")
	animator.play("idle")
	idle_timer.set_wait_time(idle_duration)
	idle_timer.start()

func _on_IdleTimer_timeout():
	animator.play("fadeout")
	yield(animator, "finished")
	emit_signal("laser_end")
	#print("Bullet Fade")
	self.queue_free()
