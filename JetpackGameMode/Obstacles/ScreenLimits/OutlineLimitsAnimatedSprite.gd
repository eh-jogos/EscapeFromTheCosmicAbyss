extends "res://JetpackGameMode/Obstacles/ScreenLimits/LimitsAnimatedSprite.gd"

func colors_changed():
	set_modulate(Global.savedata.colors.waves.outline)
