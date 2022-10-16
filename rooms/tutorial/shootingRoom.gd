extends Node2D

var next_scene = "res://rooms/tutorial/abilityRoom.tscn"
var next_next_scene = null
var hero
var TextBox = null
onready var ROOT = get_parent()
var text_script = "res://dialogue/tutorial/ACT_2.json"

var bullets = []

func _process(delta):
	if TextBox == null:
		for child in ROOT.get_children():
			if "TextBox" in child.name:
				TextBox = child
	else:
		if TextBox.text_queue.size() == 0 and TextBox.current_state == TextBox.State.FINISH :
			TextBox.queue_free()
			for child in $YSort.get_children():
				if ! child.get_groups().has("hero"):
					child.wake($YSort/hero)
