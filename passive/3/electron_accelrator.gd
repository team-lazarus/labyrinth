extends "res://passive/passive.gd"

var DMG_INCREMENT = 1

func buff():
	user.weapon.damage += DMG_INCREMENT

func remove_buff():
	user.weapon.damage -= DMG_INCREMENT
	
