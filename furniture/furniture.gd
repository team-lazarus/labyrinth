extends StaticBody2D

var health = 30

func _process(delta):
	if health < 1:
		queue_free()

func deal_damage(dmg):
	health -= dmg
