extends "res://weapons/guns/gun.gd"

func _ready():
	BULLET_INTERVAL = 0.2
	COOLDOWN = 2
	MAX_BULLETS_FIRED = 1
	
	ATTACK_ANIMATION = $AnimationPlayer.get_animation("charge").length
	
	Bullet = preload("res://characters/Hostiles/wheel_bot/wheel_bot_bullet.tscn")

func make_rotated_bullet(theta: float):
	var b = summon_bullet()

	b.hostile_group = hostile_group
	b.friendly_group = friendly_group
	b.global_transform = $muzzle.global_transform
	b.transform = b.transform.rotated(theta)	
	b.transform = b.transform.scaled(Vector2.ONE*0.8)
	b.position = $muzzle/bullet_exit.global_position
	b.user = get_parent()

	return b

func create_bullet():
	var angles = [-3*PI/24,-PI/24,PI/24, 3*PI/24]
	for angle in angles:
		get_tree().root.get_child(0).add_child(make_rotated_bullet(angle))
