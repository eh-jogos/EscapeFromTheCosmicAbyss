extends ParallaxBackground

var active_background_bosses

func _ready():
	reset_background_bosses_list()


func reset_background_bosses_list():
	active_background_bosses = []


func set_background_bosses(boss_dict, object_spawner):
	reset_background_bosses_list()
	for key in boss_dict.keys():
		if has_node(key):
			var boss_node = get_node(key)
			active_background_bosses.append(boss_node)
			boss_node.set_bg_boss_data(boss_dict[key].countdowns,boss_dict[key].animations)
			if not object_spawner.is_connected("beat_spawned", boss_node, "_on_beat_spawned"):
				object_spawner.connect("beat_spawned", boss_node, "_on_beat_spawned")
		else:
			print("ParallaxBackground | set_background_bosses | Invalid Boss Node Name: %s"%[key])
			assert(false)


func restart_background_bosses_count():
	for boss in active_background_bosses:
		boss.restart_count()