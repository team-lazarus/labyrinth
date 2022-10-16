extends StaticBody2D

# teleporter should always have the next room's file location with its owner
# teleporter should also be the direct child of the node

var ROOT

onready var Interactor = $interaction
var TextBox = preload("res://UI/Textbox/TextBox.tscn")

func _physics_process(delta):
	var bodies = Interactor.get_overlapping_bodies()
	for body in bodies :
		if (body.get_groups().has("hero")):
			if Input.is_key_pressed(KEY_E) and ! $AnimationPlayer.is_playing():
				$AnimationPlayer.play("teleport")

func render_room():
	var path = get_parent().next_scene
	var hero = get_parent().hero
	
	remove_text_box(hero.ROOT_NODE)
	
	var scene = load(path)
	var room = scene.instance()
	get_parent().get_parent().add_child(room)	
	
	get_parent().get_node("YSort").remove_child(hero)
	room.hero = hero
	
	ROOT = hero.ROOT_NODE
	
	for child in room.get_children():
		if child.name == "YSort":
			print("adding to ysort")
			child.add_child(hero)
			hero.global_position = Vector2.ZERO
	
	if room.text_script != null:
		write_text(room.text_script)
	
	get_parent().queue_free()

func remove_text_box(root):
	var text_box 
	
	for child in root.get_children():
		if "TextBox" in child.name:
			text_box = child
	
	if text_box != null:
		text_box.queue_free()

func write_text(path):
	var text_box = TextBox.instance()
	ROOT.add_child(text_box)
	
	var file = File.new()
	file.open(path, file.READ)
	var json = file.get_as_text()
	var dialogue_queue = JSON.parse(json).result
	
	file.close()
	
	
	text_box.show_textbox()
	text_box.current_state = text_box.State.READY
	
	for item in dialogue_queue:
		var data = item.split(":")
		text_box.queue_text({"speaker_name" : data[0] + ":", "dialogue" : data[1]})
	
	text_box.show_textbox()


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "teleport":
		render_room()
