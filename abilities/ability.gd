extends Node2D

var ready = true
var cooldown = 3
var user

func use():
	$cooldown.wait_time = cooldown
	ready = false
	return $cooldown

func get_cooldown_timer():
	return $cooldown

func clean_up():
	pass

func apply_modifier(subject,modifier_path):
	var modifier = load(modifier_path)
	var instance = modifier.instance()
	
	instance.subject = subject
	instance.location = subject.modifiers.size()
	
	subject.modifiers.append(instance)
	subject.add_child(instance)

func _on_cooldown_timeout():
	ready = true
	clean_up()
	
