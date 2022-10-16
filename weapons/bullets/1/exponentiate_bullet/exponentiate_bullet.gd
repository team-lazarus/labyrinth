extends "res://weapons/bullets/bullet.gd"

export var max_enemies_hit = 3
var enemies_hit = 0
var base_dmg = 2
var speed_reduction = 75

func _on_bullet_area_entered(area):
	if area.get_owner() != null and area.name == "hitbox":
		var body = area.get_owner()
		if body.is_in_group(hostile_group):
			if friendly_group == "hero":
				user.passive.on_enemy_hit()
			
			damage += base_dmg * (enemies_hit)
			enemies_hit += 1
			speed -= speed_reduction * (enemies_hit)
			
			body.deal_damage(damage)
			if enemies_hit >= max_enemies_hit:
				die()
		elif body.is_in_group(friendly_group):
			return
