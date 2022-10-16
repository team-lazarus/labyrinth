extends "res://abilities/ability.gd"

var FLARE_BULLET = preload("res://weapons/bullets/flare/flare.tscn")

func _ready():
	cooldown = 6
	$cooldown.wait_time = cooldown
	
	ready = true

func use ():
	ready = false
	
	for pos in $exit_points.get_children():
		var bullet = FLARE_BULLET.instance()
		
		bullet.hostile_group = user.hostile_group
		bullet.friendly_group = user.friendly_group
		
		bullet.global_transform = pos.global_transform
		
		user.ROOT_NODE.add_child(bullet)
	
	$cooldown.start()
	
	return $cooldown
