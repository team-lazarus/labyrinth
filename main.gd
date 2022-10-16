extends Node2D

onready var TextBox = $TextBox

func _ready():
	pass

func dialogue():
	var file = File.new()
	file.open("res://dialogue/tutorial/ACT_1.json", file.READ)
	var json = file.get_as_text()
	var dialogue_queue = JSON.parse(json).result
	file.close()
	
	for item in dialogue_queue:
		var data = item.split(":")
		$TextBox.queue_text({"speaker_name" : data[0] + ":", "dialogue" : data[1]})
	
	$TextBox.show_textbox()
	$TextBox.current_state = $TextBox.State.READY
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
