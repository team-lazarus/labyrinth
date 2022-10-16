extends "res://abilities/ability.gd"

func _ready():
	$cooldown.wait_time = 2

func use():
	ready = false
	apply_modifier(user,"res://modifiers/phased/phased.tscn")
	$cooldown.start()
	
	return $cooldown

func _on_cooldown_timeout():
	ready = true
