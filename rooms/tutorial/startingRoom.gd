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

var viable_enemies = [
	"res://characters/Hostiles/wheel_bot/wheel_bot.tscn",
	"res://characters/Hostiles/twinshot_bot/twinshot_bot.tscn",
	"res://characters/Hostiles/gatling_bot/gatling_bot.tscn",
	"res://characters/Hostiles/shotgun_bot/shotgun_bot.tscn"
	]

func _process(delta):
	current_enemies = -1
	# - 1 for hero
	for child in $YSort.get_children():
		if child is KinematicBody2D:
			current_enemies += 1
	
	if current_enemies == 0:
		var num_enemies = 0
		while num_enemies < (randi()%5)+1:
			var enemy_path = viable_enemies[randi() % viable_enemies.size()]
			var enemy = load(enemy_path).instance()
			
			var x = randf()*800
			var y = randf()*400
			
			var spawn = Vector2(x, y)
			enemy.position = spawn
			$YSort.add_child(enemy)
			enemy.wake($YSort/hero)			
			num_enemies += 1
