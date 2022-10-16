extends "res://weapons/guns/gun.gd"

func _ready():
	BULLET_INTERVAL = 0.2
	COOLDOWN = 2
	MAX_BULLETS_FIRED = 1
	
	ATTACK_ANIMATION = $AnimationPlayer.get_animation("charge").length
	
	Bullet = preload("res://characters/Hostiles/wheel_bot/wheel_bot_bullet.tscn")
