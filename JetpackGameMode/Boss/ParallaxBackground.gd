extends ParallaxBackground

func set_background_bosses(boss_node_name, laser_countdowns, animation_countdowns, animations):
	var boss_node = null
	if has_node(boss_node_name):
		boss_node = get_node(boss_node_name)
		boss_node.set_boss_data(laser_countdowns, animation_countdowns, animations)
	else:
		print("ParallaxBackground | set_background_bosses | Invalid Boss Node Name: %s"%[boss_node_name])
		assert(false)
	
	return boss_node
