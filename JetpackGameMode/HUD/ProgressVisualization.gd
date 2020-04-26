extends CenterContainer

export(int) var player_icon_x_offset = -60
export(int) var player_icon_finish_position = 1470
export(int) var initial_margin = 80
export(int) var ending_margin = 15
export(PackedScene) var progress_barrier

var progress_bar
var icon
var icon_length
var icon_position
var total_length
var increment
var total_count
var progress_count = 0

var barriers = []

func _ready():
	progress_bar = get_node("BarBase")
	icon = get_node("BarBase/IconContainer")
	icon_length = icon.get_size().x
	icon_position = icon.get_position()  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	
	total_length = progress_bar.get_size().x - initial_margin - ending_margin
	Global.connect("barrier_tentacle_killed", self, "_on_Global_barrier_tentacle_killed")


func create_barrier(step):
	var barrier = progress_barrier.instance()
	progress_bar.add_child(barrier, true)
	var position_x = (step * increment)
	var offset_x = barrier.offset_x
	var offset_y = barrier.offset_y
	barrier.set_position(Vector2(position_x + offset_x, offset_y))  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	barriers.append(barrier)


func generate_visualization(level_data):
	total_count = level_data["total_count"]
	progress_count = 0
	increment = float(total_length)/total_count
	
	print("Total Count: %s | increment: %s | TCxI: %s | TLength: %s"%[
			total_count,
			increment,
			total_count*increment,
			total_length
	])
	
	var addition = 1
	var step = 0
	var limit = level_data["half_beats"].size()
	for x in range(0, limit):
		step = x + addition
		if level_data["beats"][x] == 4:
			create_barrier(step)
		
		addition += 1
		step = x + addition
		if level_data["half_beats"][x] == 4:
			create_barrier(step)
		
		if x == limit-1:
			x = limit
			step = x + addition
			if level_data["beats"][x] == 4:
				create_barrier(step)
	
	icon_position.x = initial_margin + player_icon_x_offset
	icon.set_position(icon_position)  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review


func update_progress():
	if progress_count <= total_count:
		
		if progress_count == total_count:
			icon_position.x = player_icon_finish_position
#		elif progress_count == 1:
#			icon_position.x = initial_margin
		else:
			icon_position.x += increment
		
		icon.set_position(icon_position)  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
		progress_count += 1


func _on_Global_barrier_tentacle_killed():
	if barriers.size() > 0:
		var tween = get_node("Tween")
		tween.interpolate_property(barriers[0], "visibility/opacity", 1.0, 0.0, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.start()
		yield(tween, "tween_completed")
		barriers[0].queue_free()
		barriers.pop_front()
