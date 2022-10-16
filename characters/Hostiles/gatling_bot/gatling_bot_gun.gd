extends "res://weapons/guns/gun.gd"

func _ready():
	COOLDOWN = 0.1
	MAX_BULLETS_FIRED = 1
	
	ATTACK_ANIMATION = 0.1
	
	Bullet = preload("res://characters/Hostiles/wheel_bot/wheel_bot_bullet.tscn")
	
	$cooldown.wait_time = COOLDOWN
	$shoot_delay.wait_time = ATTACK_ANIMATION
