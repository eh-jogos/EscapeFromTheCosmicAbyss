extends "res://JetpackGameMode/Obstacles/ScreenLimits/LimitsAnimatedSprite.gd"

func colors_changed():
	self_modulate = Global.savedata.colors.waves.outline

