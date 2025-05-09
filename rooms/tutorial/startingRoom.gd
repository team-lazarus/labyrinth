extends Node2D

# var next_scene = "res://rooms/tutorial/shootingRoom.tscn"
var next_scene = "res://rooms/level1/lvl1.tscn"
var next_next_scene = null
onready var hero = load("res://characters/Hero/hero.tscn").instance()
onready var label = $Label
onready var tile_map = $TileMap
onready var stale_timer = $StaleTimer

onready var doors = [$door]

var text_script = null

onready var bullets = []
onready var enemies = []

var positions = [
	Vector2(64,1118),
	Vector2(720, 1328)
]

var backdoor = false

var current_enemies = 1

const X_MAX = 1380
const Y_MAX = 320

const X_o = -96
const Y_o = 1072

var hero_reward = 0
var gun_reward = 0

var wave = 0

func _ready():
	for child in $YSort.get_children():
		remove_child(child)
		child.queue_free()
		
	#randomize()
	var x = X_o + randf()*X_MAX
	var y = Y_o + randf()*Y_MAX
	
	var spawn = Vector2(640, 640)
	hero.global_position = spawn
	#randomize()
	$YSort.add_child(hero)

var viable_enemies = [
	"res://characters/Hostiles/twinshot_bot/twinshot_bot.tscn",
	"res://characters/Hostiles/gatling_bot/gatling_bot.tscn",
	"res://characters/Hostiles/shotgun_bot/shotgun_bot.tscn",
	#"res://characters/Hostiles/wheel_bot/wheel_bot.tscn"
	]

func _process(delta):
	current_enemies = -1
	seed(72)
	# - 1 for hero
	for child in $YSort.get_children():
		if child is KinematicBody2D:
			current_enemies += 1
	
	
	if current_enemies == 0:
		hero_reward += 5 if wave > 0 else 0
		gun_reward += 5 if wave > 0 else 0
		hero.heal(3 if wave >0 else 0)
		var num_enemies = 0
		for position in positions:
			var enemy_path = viable_enemies[randi() % viable_enemies.size()]
			var enemy = load(enemy_path).instance()
			#randomize()
			
			var x = X_o + randf()*X_MAX
			var y = Y_o + randf()*Y_MAX
			
			var spawn = position
			#randomize()
			enemy.global_position = spawn
			enemy.level = self
			$YSort.add_child(enemy)
			enemy.wake($YSort/hero)
			num_enemies += 1
			stale_timer.start()
		wave += 1

func get_enemies():
	var enemies = []
	for child in $YSort.get_children():
		if child is KinematicBody2D and not child.name.begins_with("hero"):
			enemies.append(child)
	return enemies

func cleanup():
	for child in $YSort.get_children():
		remove_child(child)
		child.queue_free()
		


func _on_StaleTimer_timeout():
	hero.deal_damage(10)
