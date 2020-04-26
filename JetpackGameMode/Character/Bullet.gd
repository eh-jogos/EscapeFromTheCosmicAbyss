extends Area2D

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
	idle_duration = 1.5
	
	set_physics_process(true)  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	pass

func _physics_process(delta):  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	#print("Bullet Processing")
	#var colliders = get_overlapping_bodies()
#	if colliders.size() > 0:
#		print(colliders)
#	for collider in colliders:
#		if collider.is_in_group("pipes"):
#			print("Bullet HIT")
#			collider.emit_signal("die")
#		else:
#			prin("Collider: %s"%[collider.get_name()])
	pass
	
func start_idle_timer():
	#print("Bullet Idle")
	animator.play("idle")
	idle_duration = idle_duration - 0.3 - 0.5
	idle_timer.set_wait_time(idle_duration)
	idle_timer.start()

func _on_idle_timeout():
	animator.play("fadeout")
	yield(animator, "animation_finished")
	emit_signal("laser_end")
	#print("Bullet Fade")
	self.queue_free()


func _on_Bullet_body_enter( body ):
	print("Collider: %s"%[body.get_name()])
	if body.is_in_group("pipes"):
		print("Bullet HIT")
		body.emit_signal("die")


func _on_CollisionShape2D_item_rect_changed():
	print("SHAPE CHANGED")
	self.set_position(get_position())  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	pass # replace with function body

