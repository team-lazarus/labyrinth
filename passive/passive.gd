extends Node2D

var user

func _ready():
	buff()

func on_enemy_hit():
	pass

func buff():
	pass

func remove_buff():
	pass

func on_enemy_death():
	pass

func on_get_hit(dmg):
	return dmg

func _on_area_of_effect_body_entered(body):
	pass

func _on_area_of_effect_body_exited(body):
	pass 

func on_remove():
	remove_buff()

func apply_modifier(subject,modifier_path):
	var modifier = load(modifier_path)
	var instance = modifier.instance()
	
	instance.subject = subject
	instance.location = subject.modifiers.size()
	
	subject.modifiers.append(instance)
	subject.add_child(instance)
	
	return instance
