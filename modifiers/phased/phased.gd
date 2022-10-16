extends "res://modifiers/modifier.gd"

func _ready():
	modifier_name = "phased"
	duration = 1.2
	
	activate()

func activate():
	subject.get_node("Sprite").material.set_shader_param("line_thickness",1)
	subject.get_node("phase_trail").show()
	
	subject.move_speed *= 1.5
	subject.accelration *= 3
	subject.collision_layer = 0b00000000000000100000
	subject.collision_mask = 0b00000000000000001000
	
	subject.get_node("hitbox").collision_layer = 0b00000000000000100000
	subject.get_node("hitbox").collision_mask = 0b00000000000000001000
	
	wait_time = duration
	$effect_timer.wait_time = duration - 0.6
	start()
	$effect_timer.start()

func deactivate():
	subject.get_node("Sprite").material.set_shader_param("line_thickness",0)
	subject.get_node("phase_trail").hide()
	
	subject.move_speed /= 1.5
	subject.accelration /= 3
	
	subject.collision_layer = 0b00000000000000000001
	subject.collision_mask = 0b00000000000000011110
	
	subject.get_node("hitbox").collision_layer = 0b00000000000000000001
	subject.get_node("hitbox").collision_mask = 0b00000000000000011110
	
	subject.modifiers.remove(location)
	queue_free()


func _on_effect_timer_timeout():
	if !self.is_stopped():
		$effect_timer.wait_time = 0.15
		if subject.get_node("Sprite").material.get_shader_param("line_thickness") == 1:
			subject.get_node("Sprite").material.set_shader_param("line_thickness",0)
		else:
			subject.get_node("Sprite").material.set_shader_param("line_thickness",1)
		$effect_timer.start()
	else:
		subject.get_node("Sprite").material.set_shader_param("line_thickness",0)
	
