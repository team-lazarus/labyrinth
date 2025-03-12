extends Node2D

# var next_scene = "res://rooms/tutorial/shootingRoom.tscn"
var next_scene = "res://rooms/level1/lvl1.tscn"
var next_next_scene = null
onready var hero = $YSort/hero

var text_script = null

var bullets = []
var doors = []
var enemies = []

var backdoor = false

func _ready():
	$YSort/shotgun_bot.wake($YSort/hero)
