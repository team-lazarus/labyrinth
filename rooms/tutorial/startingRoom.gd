extends Node2D

# var next_scene = "res://rooms/tutorial/shootingRoom.tscn"
var next_scene = "res://rooms/level1/lvl1.tscn"
var next_next_scene = null
onready var hero = load("res://characters/Hero/hero.tscn").instance()
onready var label = $Label

var text_script = null

onready var bullets = []
onready var doors = []
onready var enemies = []

var backdoor = false

var current_enemies = 1

const X_MAX = 900
const Y_MAX = 300

var hero_reward = 0
var gun_reward = 0

var wave = 0

func _ready():
	for child in $YSort.get_children():
		remove_child(child)
		child.queue_free()
		
	randomize()
	var x = randf()*X_MAX
	var y = 100 + randf()*Y_MAX
	
	var spawn = Vector2(x, y)
	hero.position = spawn
	randomize()
	$YSort.add_child(hero)

var viable_enemies = [
	"res://characters/Hostiles/twinshot_bot/twinshot_bot.tscn",
	"res://characters/Hostiles/gatling_bot/gatling_bot.tscn",
	"res://characters/Hostiles/shotgun_bot/shotgun_bot.tscn",
	#"res://characters/Hostiles/wheel_bot/wheel_bot.tscn"
	]

func _process(delta):
	current_enemies = -1
	# - 1 for hero
	for child in $YSort.get_children():
		if child is KinematicBody2D:
			current_enemies += 1
	
	
	if current_enemies == 0:
		hero_reward += 5 if wave > 0 else 0
		gun_reward += 5 if wave > 0 else 0
		hero.heal(3 if wave >0 else 0)
		var num_enemies = 0
		while num_enemies < (randi()%3)+1:
			var enemy_path = viable_enemies[randi() % viable_enemies.size()]
			var enemy = load(enemy_path).instance()
			randomize()
			
			var x = randf()*X_MAX
			var y = 100 + randf()*Y_MAX
			
			var spawn = Vector2(x, y)
			randomize()
			enemy.position = spawn
			enemy.level = self
			$YSort.add_child(enemy)
			enemy.wake($YSort/hero)			
			num_enemies += 1
		wave += 1

func cleanup():
	for child in $YSort.get_children():
		remove_child(child)
		child.queue_free()
		
