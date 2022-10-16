extends KinematicBody2D

const FRICTION = 15

var direction = Vector2.ZERO
var maginitude_velocity = 50
var velocity = Vector2.ZERO

var dir_init = false

func _process(delta):
	if direction != Vector2.ZERO and !dir_init:
		velocity =  (maginitude_velocity * Vector2.ONE).rotated((direction.angle() - PI/4) + (randi() * PI)/2)
		dir_init = true
func _physics_process(delta):
	velocity = velocity.move_toward(Vector2.ZERO,FRICTION * delta)
	velocity = move_and_slide(velocity)

func on_pick(hero):
	pass


func _on_AOE_body_entered(body):
	if body.get_groups().has("hero"):
		on_pick(body)
