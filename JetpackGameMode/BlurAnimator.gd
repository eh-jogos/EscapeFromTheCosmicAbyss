extends AnimationPlayer

func _ready():
	yield(owner, "ready")
	
	play("base")
