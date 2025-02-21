extends "res://characters/Hostiles/hostile.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	enemy_type = "sniper_bot"
	
	rays.resize(num_rays)
	for itr in range(num_rays):
		var path = str(itr)
		var node = get_node(path)
		var angle = itr * 2 * PI / num_rays
		
		node.cast_to = Vector2(0,RAY_CAST_LENGTH).rotated(angle)
		rays[itr] = node
	
	strength = 2
	health = 10
	
	$AnimationPlayer.play("idle")
