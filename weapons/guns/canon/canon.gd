extends "res://weapons/guns/gun.gd"

func _ready():
	BULLET_INTERVAL = 0.2
	COOLDOWN = 0.2
	MAX_BULLETS_FIRED = 1
	ATTACK_ANIMATION = 0.2
	
	ATTACK_ANIMATION = $AnimationPlayer.get_animation("charge").length
	
	
	Bullet = preload("res://weapons/bullets/canon/canon_bullet.tscn")
	
	$cooldown.wait_time = COOLDOWN
	$shoot_delay.wait_time = ATTACK_ANIMATION
	
	state = State.READY
	
	$AnimationPlayer.play("ready")

