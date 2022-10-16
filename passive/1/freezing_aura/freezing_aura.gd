extends "res://passive/passive.gd"

var instance_dict = {}

func _on_area_of_effect_body_entered(body):
	var instance = apply_modifier(body,"res://modifiers/slowed/slowed.tscn")
	instance.duration = null
	instance_dict[body.name] = instance

func _on_area_of_effect_body_exited(body):
	instance_dict[body.name].deactivate()
	instance_dict[body.name] = null
