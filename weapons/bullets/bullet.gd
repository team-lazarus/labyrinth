extends Area2D

export var MAX_DISTANCE = 600
export var MIN_DISTANCE = 50

export var hostile_group = ""
export var friendly_group = ""
export var damage = 1
var spawn_position

var user
export var speed = 150

func _ready():
	spawn_position = global_position
	
func _physics_process(delta):
	if global_position.distance_to(spawn_position) > MAX_DISTANCE:
		die()
	position += transform.x * speed * delta

func _on_bullet_area_entered(area):
	if area.get_owner() != null and area.name == "hitbox":
		var body = area.get_owner()
		if body.is_in_group(hostile_group):
			if friendly_group == "hero":
				user.passive.on_enemy_hit()
			body.deal_damage(damage)
		elif body.is_in_group(friendly_group):
			return
		die()

func _on_bullet_body_entered(body):
	if body.is_in_group("wall") and global_position.distance_to(spawn_position) > MIN_DISTANCE:
		die()

func die ():
	queue_free()
