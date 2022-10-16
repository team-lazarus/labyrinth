extends "res://passive/passive.gd"

var souls = 0
var soul_dmg_buff = 0.25
var MAX_SOULS = 20

var total_damage_buff = 0

func buff():
	if souls > 0 and souls <= MAX_SOULS:
		total_damage_buff += soul_dmg_buff
		user.weapon.damage += soul_dmg_buff
	elif souls == 0:
		user.weapon.damage -= total_damage_buff
	elif souls > MAX_SOULS:
		souls = MAX_SOULS

func remove_buff():
	souls = 0

func on_enemy_death():
	souls += 1
	buff()
