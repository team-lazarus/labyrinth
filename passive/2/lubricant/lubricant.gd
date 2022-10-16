extends "res://passive/passive.gd"

var MOVESPEED_INCREMENT = 1.25 # percent

func buff():
	user.move_speed *= MOVESPEED_INCREMENT

func remove_buff():
	user.move_speed /= MOVESPEED_INCREMENT
