extends Node2D

# set follow to NULL if the gun is to be manually fired
# these constants can be changed to create new gun really fast
export var BULLET_INTERVAL = 0.2
export var COOLDOWN = 1.0
export var MAX_BULLETS_FIRED = 1

onready var ATTACK_ANIMATION = $AnimationPlayer.get_animation("charge").length

# these need to be initialised
export var Bullet = preload("res://weapons/bullets/bullet.tscn")
export var ready = true
var follow
export var hostile_group = ""
export var friendly_group = ""
var state = State.READY

var num_bullets = 0

enum State {
	FIRING,
	READY,
	RECHARGING
}

func _ready():
	$cooldown.wait_time = COOLDOWN
	$shoot_delay.wait_time = ATTACK_ANIMATION
	# $AnimationPlayer.play("ready")

func _physics_process(delta):
	if ready:
		if follow != null:
			$muzzle.look_at(follow.global_position)

func shoot():
	if state == State.READY:
		state = State.FIRING
		
		$shoot_delay.start()
		$shoot_sound.play()
		# $AnimationPlayer.play("charge")

func shoot_at(angle: float):
	$muzzle.transform = Transform2D(angle, $muzzle.transform.get_origin())
	print($muzzle.transform)
	print(angle)
	shoot()

func create_bullet():
	var b = summon_bullet()
	
	b.hostile_group = hostile_group
	b.friendly_group = friendly_group
	b.transform = $muzzle.global_transform
	b.position = $muzzle/bullet_exit.global_position
	b.user = get_parent()
	
	get_tree().root.get_child(0).add_child(b)

func summon_bullet():
	var b = Bullet.instance()
	if ! get_parent().get_parent().get_groups().has("hero"):
		get_parent().get_parent().get_parent().bullets.append(b)
	
	return b

func _on_shoot_delay_timeout():
	state = State.RECHARGING
	
	$cooldown.start()
	create_bullet()



func _on_cooldown_timeout():
	state = State.READY
	# $AnimationPlayer.play("ready")
