extends CenterContainer

export(int) var ending_cap = 0
export(PackedScene) var progress_barrier

var progress_bar
var icon
var icon_position
var total_length
var increment
var total_count
var progress_count = 0

func _ready():
	progress_bar = get_node("ProgressBar")
	icon = get_node("ProgressBar/IconContainer")
	icon_position = icon.get_pos()
	
	total_length = progress_bar.get_texture().get_width() - ending_cap


func create_barrier(step):
	var barrier = progress_barrier.instance()
	var position = step * increment
	barrier.set_pos(Vector2(position, 4))
	progress_bar.add_child(barrier)


func generate_visualization(level_data):
	total_count = level_data["total_count"]
	increment = total_length/total_count
	
	var addition = 0
	var step = 0
	var limit = level_data["half_beats"].size()
	for x in range(limit):
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
	
	icon_position.x = 0
	icon.set_pos(icon_position)

func update_progress():
	if progress_count < total_count:
		progress_count += 1
		
		if progress_count == total_count:
			icon_position.x = total_length
		else:
			icon_position.x += increment
		
		icon.set_pos(icon_position)