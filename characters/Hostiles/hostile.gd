extends KinematicBody2D

onready var AnimationHandler = $AnimationPlayer
onready var weapon = $weapon
onready var hitbox = $hitbox

enum State {
	SLEEP,
	AWAKE
}

var MAXIMUM_BOT_VELOCITY = 270
const BOT_ACCELRATION = 1000
const RAY_CAST_LENGTH = 50
const HERO_DISTANCE = 200
const MAX_HEALTH = 4

var current_state = State.AWAKE
var hero_shootable = false
var hero

var hostile_group = "hero"
var friendly_group = "hostile"
var health = 10
var strength = 1
var bot_direction = Vector2.ZERO
var level = null

# context based steering
var rays = []

export var num_rays = 32

var chosen_dir = Vector2.ZERO
var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO

var init_done = false

var modifiers = []

var enemy_type = -1
var shot = false
var SHOT_REWARD = 2.5

var i_wanna_be_closer_baby = 1

func _ready():
	rays.resize(num_rays)
	for itr in range(num_rays):
		var path = str(itr)
		var node = get_node(path)
		var angle = itr * 2 * PI / num_rays
		
		node.cast_to = Vector2(0,RAY_CAST_LENGTH).rotated(angle)
		node.transform.scaled(Vector2.ONE * 2)
		rays[itr] = node
	

func _process(delta):
	if health < 1 :
		die()
	elif health > MAX_HEALTH:
		health = MAX_HEALTH
	if hero != null:
		fix_sprite_direction()
		follow(delta)
		shoot()

func fix_sprite_direction():
	$Sprite.transform.rotated(velocity.angle())

func wake (body):
	current_state = State.AWAKE
	
	weapon.follow = body
	weapon.hostile_group = hostile_group
	weapon.friendly_group = friendly_group
	
	get_node("Timer").start()

func shoot ():
	if ($weapon.state == $weapon.State.READY):
		$weapon.shoot()

func _on_AnimationPlayer_animation_finished(anim_name):
	if (anim_name == "shoot"):
		current_state = State.AWAKE
		$AnimationPlayer.play("move")
	elif anim_name == "wake":
		$AnimationPlayer.play("move")

func follow(delta):
	var direction = raycast_check()
	bot_direction = direction
	velocity += direction * BOT_ACCELRATION * delta
	velocity = velocity.clamped(MAXIMUM_BOT_VELOCITY)
	
	velocity = move_and_slide(velocity)

func raycast_check():
	var dir = Vector2.ZERO
	#if global_position.distance_to(hero.global_position) > HERO_DISTANCE:
	dir = global_position.direction_to(hero.global_position).normalized()
	#else:
	#	dir = hero.position.direction_to(position)
	
	var eligible_rays = Vector2.ZERO
	for ray in rays:
		if ray.get_collider() != null:
			var weight 
			var factor = dir.dot(ray.cast_to.normalized())
			if ray.get_collider().get_groups().has("hostile"):
				weight =-1
			elif ray.get_collider().get_groups().has("hero"):
				weight = i_wanna_be_closer_baby * 5
			elif ray.get_collider().get_groups().has("wall"):
				weight = -0.5
			else :
				weight = 0
			eligible_rays += ray.cast_to.normalized()  * weight
	
	dir += eligible_rays.normalized()
	
	return dir.normalized()

func deal_damage(dmg):
	flash()
	print("i got hit!")
	level.gun_reward += dmg * SHOT_REWARD
	print("adding gun reward")
	health -= dmg

func flash():
	print("flashing")
	$Sprite.material.set_shader_param("flash_modifier",1)
	$weapon/muzzle/Sprite.material.set_shader_param("flash_modifier",1)
	$flashTimer.start()


func _on_flashTimer_timeout():
	$Sprite.material.set_shader_param("flash_modifier",0)
	$weapon/muzzle/Sprite.material.set_shader_param("flash_modifier",0)

func die ():
	#hero.passive.on_enemy_death()
	queue_free()

func _on_Timer_timeout():
	hero = $weapon.follow
