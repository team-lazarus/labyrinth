extends "res://weapons/bullets/bullet.gd"

func _ready():
	bullet_type = "hero_bullet"
	spawn_position = global_position
	speed = 325
