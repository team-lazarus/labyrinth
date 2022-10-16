extends "res://weapons/guns/gun.gd"

var itr = 0
var bullets = 4

func _ready():
	BULLET_INTERVAL = 0.2
	COOLDOWN = 6
	MAX_BULLETS_FIRED = 1
	
	ATTACK_ANIMATION = $AnimationPlayer.get_animation("charge").length
	
	Bullet = preload("res://characters/Hostiles/twinshot_bot/twinshot_bullet.tscn")
	
	$cooldown.wait_time = COOLDOWN
	$shoot_delay.wait_time = ATTACK_ANIMATION
	$AnimationPlayer.play("ready")

func create_bullet():
	$bullet_interval.start()
	

func _on_bullet_interval_timeout():
	if itr <= bullets:
		$shoot_sound.play()
		var b = summon_bullet()
		b.hostile_group = hostile_group
		b.friendly_group = friendly_group
		b.global_transform = $muzzle/bullet_exit.global_transform
		get_tree().root.get_child(0).add_child(b)
			
		itr += 1
		$bullet_interval.start()
	else:
		itr = 0
