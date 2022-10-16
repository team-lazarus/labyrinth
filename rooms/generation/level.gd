extends Node2D

var hero = null
var next_scene = null
var next_next_scene = null
var text_script = null

var wave_strength = 2
var wave_strength_increment = 1

var total_waves = 3
var num_of_waves = 0

var create_new_wave = true
var current_wave_strength = 0
var total_enemies_spawned = 0
var current_enemies = 0
var initial_elements

var bullets = []
var doors = []

var loot_crate = preload("res://furniture/loot_crate.tscn").instance()

# weights are indexed like this
# C tier : 3
# B tier : 2
# A tier : 1
# S tier : 0
# S tier is usually kept at a constant 0.02 probablity
var weights = [
	0.02,0.1,0.37,0.5
]

var loot_generation_probability = 0.2

var viable_enemies = [
	"res://characters/Hostiles/wheel_bot/wheel_bot.tscn",
	"res://characters/Hostiles/shotgun_bot/shotgun_bot.tscn",
	"res://characters/Hostiles/twinshot_bot/twinshot_bot.tscn",
	"res://characters/Hostiles/gatling_bot/gatling_bot.tscn"
	]

onready var spawnpoints = $spawnpoints.get_children()
func _ready():
	loot_crate.loot = [
		"res://items/health/health.tscn",
		"res://items/health/health.tscn",
		"res://items/health/health.tscn"
		]
	loot_crate.weights = weights
	
	$backdoor.locked = true
	
	initial_elements = $YSort.get_children().size()


func _process(delta):
	if hero != null:
		loot_crate.hero = hero
	
	randomize()
	current_enemies = 0
	# - 1 for hero
	for child in $YSort.get_children():
		if child is KinematicBody2D:
			current_enemies += 1
	
	current_enemies -= 1
	
	if current_enemies == 0:
		create_new_wave = true
	
	if create_new_wave and num_of_waves < total_waves:
		current_enemies = create_new_wave()
	
	if num_of_waves == total_waves and current_enemies == 0 and $backdoor.locked:
		after_wave_action()
	

func create_new_wave():
	while (current_wave_strength < wave_strength):
		var enemy_path = viable_enemies[randi() % viable_enemies.size()]
		var enemy = load(enemy_path).instance()
		
		var most_viable_point = get_most_viable_point()
		
		var factor = [1,1]
		
		randomize()
		var v = randi()%5
		if v > 1:
			factor[0] = -1
		elif v > 2:
			factor[1] = -1
		elif v > 3:
			factor[0] = -1
			factor[1] = -1
		
		randomize()
		enemy.position = most_viable_point.position + Vector2(randi()%20 * factor[0], randi()%20 * factor[1])
		
		if enemy.strength <= (wave_strength - current_wave_strength):
			print("enemy str",enemy.strength)
			print("delta wave str",wave_strength - current_wave_strength)
			$YSort.add_child(enemy)
		
			enemy.wake(hero)
			current_wave_strength += enemy.strength
	
	print("creating wave")
	num_of_waves += 1
	wave_strength += wave_strength_increment
	create_new_wave = false
	current_wave_strength = 0
	
	return $YSort.get_children().size() - 1

func after_wave_action():
	$YSort.add_child(loot_crate)
	loot_crate.global_position = $loot.global_position
	
	for door in doors:
		door.locked = false
	$backdoor.locked = false
	
	loot_crate.open()
	

func get_most_viable_point():
	var nearest = spawnpoints[0]
	
	for spawnpoint in spawnpoints:
		var sp_dist = spawnpoint.global_position.distance_to(hero.global_position)
		var nearest_dist = nearest.global_position.distance_to(hero.global_position)
		if sp_dist < nearest_dist :
			nearest = spawnpoint
	
	var sps = spawnpoints.duplicate()
	sps.erase(nearest)
	
	return sps[randi()%sps.size()]
