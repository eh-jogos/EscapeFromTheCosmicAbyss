extends ParallaxBackground

export var boss_dict: Dictionary = {
	"BackRowBoss": NodePath(),
	"MidBackRowBoss": NodePath(),
	"MidFrontRowBoss": NodePath(),
}

func set_background_bosses(
			boss_node_name, 
			laser_countdowns, 
			animation_countdowns, 
			animations, 
			danger_durations
	):
	var boss_node = null
	if has_node(boss_dict[boss_node_name]):
		boss_node = get_node(boss_dict[boss_node_name])
		boss_node.set_boss_data(laser_countdowns, animation_countdowns, animations, danger_durations)
	else:
		print("ParallaxBackground | set_background_bosses | Invalid Boss Node Name: %s"%[boss_node_name])
		assert(false)
	
	return boss_node

