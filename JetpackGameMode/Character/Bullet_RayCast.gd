extends Node2D

# class member variables go here, for example:
var raycast_top
var raycast_bottom
var raycasts

var animator
var parent

var sfx_player
var sfx_voice
var is_looping_sfx = false

signal laser_end

func _ready():
	#print("Bullet Ready")
	raycast_top = get_node("TopRaycast")
	raycast_bottom = get_node("BottomRaycast")
	raycasts = [raycast_top, raycast_bottom]
	
	animator = self.get_node("AnimationPlayer")
	animator.play("fire")
	
	sfx_player = get_node("SamplePlayer")
	
	set_fixed_process(true)


func set_laser_strength(duration):
	var new_height = Vector2(1,1)
	new_height.y += duration
	self.set_scale(new_height)


func _fixed_process(delta):
	for raycast in raycasts:
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			#print(collider.get_name())
			if collider.is_in_group("pipes"):
				#print("Bullet HIT")
				collider.emit_signal("die")
	
	if is_looping_sfx and not sfx_player.is_active():
		sfx_voice = sfx_player.play("laser_loop")


func _on_AnimationPlayer_fadeout_finished():
	emit_signal("laser_end")
	#print("Bullet Fade")
	self.queue_free()


func play_fire_sfx():
	sfx_player.play("laser_firing")
	pass


func play_loop_sfx():
	sfx_voice = sfx_player.play("laser_loop")
	is_looping_sfx = true


func start_fade_out_sfx():
	var tween = get_node("Tween")
	tween.interpolate_method(self, "fade_out_sfx", 0.0, -30.0,  0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)


func fade_out_sfx(volume_db):
	sfx_player.set_volume_db(sfx_voice, volume_db)
