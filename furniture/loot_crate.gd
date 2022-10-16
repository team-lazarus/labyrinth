extends StaticBody2D

var loot = []
var hero = null
var weights = []
var loot_generation_probability = 0

func _ready():
	if loot_generation_probability != 1:
		while randi() < loot_generation_probability:
			loot.append(get_loot())
			loot_generation_probability *= loot_generation_probability
	else:
		loot.append(get_loot())

func get_loot():
	var sum = 0
	var val = randi()
	
	for i in range(weights.size()):
		sum += weights[i]
		if val < sum:
			return get_loot_from_tier(i)

func get_loot_from_tier (tier):
	var val = randi()
	
	if val < 0.3333:
		return get_ability()
	elif val < 0.66667:
		return get_gun()
	else:
		return get_passive()

func get_ability():
	pass

func get_gun():
	pass

func get_passive():
	pass

func loot():
	for l in loot:
		var loot_instance = load(l).instance()
		var direction = -1 * self.position.direction_to(hero.position)
		
		loot_instance.direction = direction
		loot_instance.global_position = global_position
		
		get_parent().add_child(loot_instance)

func open():
	$CollisionShape2D.disabled = false
	$AnimationPlayer.play("open")

func _on_AnimationPlayer_animation_finished(anim_name):
	loot()
