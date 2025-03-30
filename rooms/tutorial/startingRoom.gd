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

var current_enemies = 1

func _ready():
	$YSort/shotgun_bot.wake($YSort/hero)

func _process(delta):
	current_enemies = -1
	# - 1 for hero
	for child in $YSort.get_children():
		if child is KinematicBody2D:
			current_enemies += 1
