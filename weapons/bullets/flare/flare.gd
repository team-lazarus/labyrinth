extends "res://weapons/bullets/bullet.gd"


func _ready():
	name = "flare"
	
	damage = 1
	
	MIN_DISTANCE = 50
	MAX_DISTANCE = 100
	spawn_position = global_position
	speed = 33
