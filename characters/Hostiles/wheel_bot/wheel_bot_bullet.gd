extends "res://weapons/bullets/bullet.gd"

func _ready():
	MAX_DISTANCE = 3000
	spawn_position = global_position
	damage = 1
	speed = 200
