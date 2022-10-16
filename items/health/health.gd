extends "res://items/item.gd"

func on_pick(hero):
	hero.heal(1)
	queue_free()

