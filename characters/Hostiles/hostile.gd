extends KinematicBody2D

onready var AnimationHandler = $AnimationPlayer
onready var weapon = $weapon
onready var hitbox = $hitbox

enum State {
	SLEEP,
	AWAKE
}

var MAXIMUM_BOT_VELOCITY = 100
const BOT_ACCELRATION = 500
const RAY_CAST_LENGTH = 50
const HERO_DISTANCE = 200
const MAX_HEALTH = 4

var current_state = State.SLEEP
var hero_shootable = false
var hero

var hostile_group = "hero"
var friendly_group = "hostile"
var health = 10
var strength = 1
var bot_direction = Vector2.ZERO

# context based steering
var rays = []

export var num_rays = 32

var chosen_dir = Vector2.ZERO
var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO

var init_done = false

var modifiers = []

var enemy_type = ""

func _ready():
	rays.resize(num_rays)
	for itr in range(num_rays):
		var path = str(itr)
		var node = get_node(path)
		var angle = itr * 2 * PI / num_rays
		
		node.cast_to = Vector2(0,RAY_CAST_LENGTH).rotated(angle)
		rays[itr] = node
	
	$AnimationPlayer.play("idle")

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
	if hero.global_position < global_position:
		$Sprite.flip_h = true
	else:
		$Sprite.flip_h = false 

func wake (body):
	AnimationHandler.play("wake")
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
	
	if position.distance_to(hero.position) > HERO_DISTANCE:
		dir = position.direction_to(hero.position)
	else:
		dir = hero.position.direction_to(position)
	
	var eligible_rays = Vector2.ZERO
	for ray in rays:
		if ray.get_collider() != null:
			var weight 
			var factor = dir.dot(ray.cast_to.normalized())
			if ray.get_collider().get_groups().has("wall"):
				weight = 0
			if ray.get_collider().get_groups().has("hostile"):
				weight = -0.1
			else :
				weight = 0.5
			eligible_rays += ray.cast_to.normalized() * factor * weight
	
	dir =  eligible_rays
	
	return dir.normalized()

func deal_damage(dmg):
	flash()
	health -= dmg

func flash():
	$Sprite.material.set_shader_param("flash_modifier",1)
	$weapon/muzzle/Sprite.material.set_shader_param("flash_modifier",1)
	$flashTimer.start()


func _on_flashTimer_timeout():
	$Sprite.material.set_shader_param("flash_modifier",0)
	$weapon/muzzle/Sprite.material.set_shader_param("flash_modifier",0)

func die ():
	hero.passive.on_enemy_death()
	queue_free()

func _on_Timer_timeout():
	hero = $weapon.follow
