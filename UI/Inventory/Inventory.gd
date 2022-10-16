extends CanvasLayer

var hidden = true
var held = false
onready var hero = get_parent().get_node("StartingRoom/YSort/hero")

func _input (event):
	if event.as_text() == "Tab":
		if event.is_pressed():
			held = true
		else:
			held = false
	
	if event.as_text() == "Tab":
		if !held:
			if hidden:
				render_inventory()
				$Control.show()
				get_tree().paused = true
			else:
				$Control.hide()
				get_tree().paused = false
				
			hidden = !hidden

func render_inventory():
	pass
