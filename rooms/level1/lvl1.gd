extends Node2D

var text_script = "res://dialogue/lvl1/ACT_1.json"
var hero = null
var next_scene = null
var next_next_scene = null

var level_quality = [10]
var level_difficulty = ["res://rooms/generation/terrain/"]
var potential_levels = []

var levels = []
var levels_not_made = true
var bullets = []

func _process(_delta):
	if $YSort/hero != null and levels_not_made:
		for ld in level_difficulty:
			potential_levels.append(list_files_in_directory(ld))
		
		for i in range(level_difficulty.size()):
			for j in range(level_quality[i] + 1):
				randomize()
				levels.append(potential_levels[i][randi()%potential_levels[i].size()])
		
		convert_to_tree()
		levels_not_made = false

func list_files_in_directory(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(path+file)

	dir.list_dir_end()

	return files

func convert_to_tree():
	var room = load(levels.pop_front()).instance()
	$door.hero = $YSort/hero
	$door.room = room
	
	room.loot_generation_probability = 1
	
	var head = {
		children = [],
		value = room
	}
	
	var _n = levels.pop_front()
	
	var itr = head
	
	while levels.size() > 0:
		randomize()
		for i in range(randi()%3 + 1):
			if levels.size() != 0:
				var lvl = levels.pop_front()
				print(lvl)
				room = load(lvl).instance()
				print(room)
				var doorpoint = itr.value.get_node("doorpoints").get_children()[i].position
				var door = preload("res://furniture/door.tscn").instance()
				
				door.position = doorpoint
				
				door.hero = $YSort/hero
				door.room = room
				
				itr.value.add_child(door)
				itr.value.doors.append(door)
				
				itr.value.wave_strength += randi()%2
				
				door.locked = true
				
				itr.children.append({
					children = [],
					value = room
				})
				
		print("....")
		
		var ysort = itr.value.get_node("YSort")
		itr.value.remove_child(ysort)
		itr.value.add_child(ysort)
		
		randomize()
		itr = itr.children[randi()%itr.children.size()]
