extends "res://characters/Hostiles/hostile.gd"

func _ready():
	enemy_type = "wheel_bot"
	
	rays.resize(num_rays)
	for itr in range(num_rays):
		var path = str(itr)
		var node = get_node(path)
		var angle = itr * 2 * PI / num_rays
		
		node.cast_to = Vector2(0,RAY_CAST_LENGTH).rotated(angle)
		rays[itr] = node
	
	strength = 1
	
	MAXIMUM_BOT_VELOCITY = 250
	
	$AnimationPlayer.play("idle")

