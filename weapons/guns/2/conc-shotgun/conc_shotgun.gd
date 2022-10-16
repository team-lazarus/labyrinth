extends "res://weapons/guns/gun.gd"

var bullets = 6

func _ready():
	BULLET_INTERVAL = 0.2
	COOLDOWN = 2
	MAX_BULLETS_FIRED = 1
	
	ATTACK_ANIMATION = $AnimationPlayer.get_animation("charge").length
	
	Bullet = preload("res://characters/Hostiles/wheel_bot/wheel_bot_bullet.tscn")
	
	$cooldown.wait_time = COOLDOWN
	$shoot_delay.wait_time = ATTACK_ANIMATION
	$AnimationPlayer.play("ready")

func create_bullet():
	for bullet_exit in $muzzle/bullet_exits.get_children():
		var b = summon_bullet()
		b.hostile_group = hostile_group
		b.friendly_group = friendly_group
		b.transform = bullet_exit.global_transform
		b.speed = 280
		get_tree().root.get_child(0).add_child(b)

