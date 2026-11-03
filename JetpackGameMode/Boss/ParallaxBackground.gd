extends ParallaxBackground

@export var boss_dict: Dictionary = {
	"BackRowBoss": NodePath(),
	"MidBackRowBoss": NodePath(),
	"MidFrontRowBoss": NodePath(),
}

func set_background_bosses(p_boss_data: BossData):
	var boss_node = null
	var boss_name = (LevelData.BossTypes.keys()[p_boss_data.boss_type] as String).to_pascal_case()
	if boss_name in boss_dict:
		boss_node = get_node(boss_name)
		boss_node.set_boss_data(p_boss_data)
	else:
		print("ParallaxBackground | set_background_bosses | Invalid Boss Node Name: %s"%[boss_name])
		assert(false)
	
	return boss_node
