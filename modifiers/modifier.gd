extends Timer

var modifier_name = ""
export var duration = 1
var subject = null
var location = -1

func _on_duration_timeout():
	deactivate()

func activate():
	pass

func deactivate():
	subject.modifiers.remove(location)
	queue_free()
