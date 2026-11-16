extends AnimationPlayer

func _ready():
	await owner.ready
	
	play("base")
