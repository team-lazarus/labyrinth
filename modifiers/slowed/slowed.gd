extends "res://modifiers/modifier.gd"

func _ready():
	modifier_name = "slow"
	duration = 2
	
	activate()

func activate():
	subject.move_speed *= 0.5
	subject.accelration *= 0.5
	
	if duration != null:
		wait_time = duration
		start()

func deactivate():
	subject.move_speed /= 0.5
	subject.accelration /= 0.5
	
	subject.modifiers.remove(location)
	queue_free()
