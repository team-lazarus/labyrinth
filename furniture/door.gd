extends StaticBody2D

# door should always have the next room's file location with its owner
# door should also be the direct child of the node

var ROOT

onready var interactor = $interaction
var TextBox = preload("res://UI/Textbox/TextBox.tscn")

var room
var hero
var spawn_loc = Vector2.ZERO
var locked = false

func _physics_process(delta):
	if hero == null and self.name != "backdoor":
		if get_parent().next_scene != null:
			room = load(get_parent().next_scene).instance()
		if get_parent().hero != null:
			hero = get_parent().hero

func _input(event):
	var bodies = interactor.get_overlapping_bodies()
	for body in bodies :
		if (body.get_groups().has("hero")):
			if Input.is_key_pressed(KEY_E) and event is InputEventKey and ! locked:
				if  ! event.echo:
					render_room()

func render_room():
	var backdoor = room.get_node("backdoor")
	
	if backdoor != null and backdoor.room == null:
		backdoor.room = get_parent()
		backdoor.hero = hero
		backdoor.spawn_loc = hero.global_position
	
	if get_parent().next_next_scene != null:
		room.next_scene = get_parent().next_next_scene
	
	room.name = "level"
	get_parent().get_parent().add_child(room)
	
	get_parent().get_node("YSort").remove_child(hero)
	room.hero = hero
	ROOT = hero.ROOT_NODE
	
	for child in room.get_children():
		if child.name == "YSort":
			child.add_child(hero)
			hero.global_position = spawn_loc
	
	
	if room.text_script != null:
		pass
		# write_text(room.text_script)
	
	get_parent().get_parent().remove_child(get_parent())

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
	text_box.text_queue = []
	
	for item in dialogue_queue:
		var data = item.split(":")
		text_box.queue_text({"speaker_name" : data[0] + ":", "dialogue" : data[1]})
	
	text_box.show_textbox()
	
	room.text_script = null
