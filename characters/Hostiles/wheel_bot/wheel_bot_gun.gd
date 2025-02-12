extends "res://weapons/guns/gun.gd"

func _ready():
	BULLET_INTERVAL = 0.2
	COOLDOWN = 2
	MAX_BULLETS_FIRED = 1
	
	ATTACK_ANIMATION = $AnimationPlayer.get_animation("charge").length
	
	Bullet = preload("res://characters/Hostiles/wheel_bot/wheel_bot_bullet.tscn")

func create_bullets():
	var bullets = []
	for i in range(4):
		var b = summon_bullet()
	
		b.hostile_group = hostile_group
		b.friendly_group = friendly_group
		b.transform = Transform2D(((i*PI)/2),$muzzle/bullet_exit.global_position)
		print(b.transform)
		b.user = get_parent()
		
		bullets.append(b)
	return bullets

func create_bullet():
	var bullets = create_bullets()
	for bullet in bullets:
		get_tree().root.get_child(0).add_child(bullet)
