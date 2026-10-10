extends CenterContainer

@export var player_icon_x_offset: int = -60
@export var player_icon_finish_position: int = 1470
@export var initial_margin: int = 80
@export var ending_margin: int = 15
@export var progress_barrier: PackedScene

var progress_bar
var icon
var icon_length
var icon_position
var total_length
var increment
var total_count
var progress_count = 0

var barriers: Array[CenterContainer] = []

var _tween: Tween = null

func _ready():
	progress_bar = get_node("BarBase")
	icon = get_node("BarBase/IconContainer")
	icon_length = icon.get_size().x
	icon_position = icon.get_position()  #-- NOTE: Automatically converted by Godot 2 to 3 converter, please review
	
	total_length = progress_bar.get_size().x - initial_margin - ending_margin
	Global.connect("barrier_tentacle_killed", Callable(self, "_on_Global_barrier_tentacle_killed"))


func create_barrier(step):
	var barrier: CenterContainer = progress_barrier.instantiate()
	progress_bar.add_child(barrier, true)
	var position_x = (step * increment)
	var offset_x = barrier.offset_x
	var offset_y = barrier.offset_y
	barrier.position = Vector2(position_x + offset_x, offset_y)
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
		var current_barrier: CenterContainer = barriers.pop_front()
		if _tween:
			if _tween.is_running():
				await _tween.finished
			_tween.kill()
		
		_tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
		_tween.tween_property(current_barrier, "modulate:a", 0.0, 0.3)
		await _tween.finished
		current_barrier.queue_free()
