extends CanvasLayer

#constants
const CHAR_READ_RATE = 0.05

#instance variables
var current_state
var text_queue = []

onready var textbox_container = $TextboxContainer
onready var speaker = $TextboxContainer/MarginContainer/HBoxContainer/speaker
onready var dialogue = $TextboxContainer/MarginContainer/HBoxContainer/dialogue
onready var end = $TextboxContainer/MarginContainer/HBoxContainer/end
onready var tween = $Tween # this is used to display the text like it is being typed

enum State {
	READY,
	READING,
	FINISH
}

func _process(delta):
	match current_state:
		State.READY:
			if !text_queue.empty():
				display_text()
			else:
				hide_textbox()
		State.READING:
			if Input.is_action_just_pressed("ui_accept"):
				dialogue.percent_visible = 1.0
				tween.stop_all()
				end.text = "v"
				change_state(State.FINISH)
		State.FINISH:
			if Input.is_action_just_pressed("ui_accept"):
				change_state(State.READY)
				clean_slate()

func clean_slate ():
	speaker.text = ""
	dialogue.text = ""
	end.text = ""

func hide_textbox ():
	clean_slate()
	textbox_container.hide()

func show_textbox():
	textbox_container.show()

func display_text ():
	var dialogue_data = text_queue.pop_front()
	
	speaker.text = dialogue_data.speaker_name
	dialogue.text = dialogue_data.dialogue
	dialogue.percent_visible = 0.0

	change_state(State.READING)
	
	tween.interpolate_property(dialogue,"percent_visible",
		0.0, 1.0, len(dialogue.text) * CHAR_READ_RATE,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


func _on_Tween_tween_all_completed():
	end.text = "v"
	
	change_state(State.FINISH)

func change_state(next_state):
	current_state = next_state

func queue_text (next_dialogue):
	text_queue.push_back(next_dialogue)
