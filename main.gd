extends Node2D

onready var TextBox = $TextBox

const SERVER_IP = "0.0.0.0"
const SERVER_PORT = 4200
onready var tcp_server = TCP_Server.new()
var peer_connections = []
var current_level = null
var previous_enemies = -1

func _ready():
	start_server()
	

func start_server():
	var err = tcp_server.listen(SERVER_PORT, SERVER_IP)
	if err != OK:
		print("[ERROR] Failed to start TCP server")
	else:
		print("[INFO] Server successfully started on port ", SERVER_PORT)

func handle_client_request(peer_index = 0):
	# 1. Send current game state
	var current_state = get_current_game_state()
	write_to_client(current_state, peer_index)
	
	# 2. Wait for and receive action from client
	var action = null
	while action == null:
		action = read_from_client(peer_index)
		if action:
			execute_actions(action)

func write_to_client(data, peer_index = 0):
	if peer_index < peer_connections.size():
		var peer = peer_connections[peer_index]
		if peer.is_connected_to_host():
			var packet = data.to_utf8()
			peer.put_data(packet)
		else:
			print("[ERROR] Client disconnected")
			peer_connections.remove(peer_index)
	else:
		print("[ERROR] Invalid peer index")

func read_from_client(peer_index = 0):
	if peer_index < peer_connections.size():
		var peer = peer_connections[peer_index]
		if peer.is_connected_to_host():
			var available_bytes = peer.get_available_bytes()
			if available_bytes > 0:
				var data = peer.get_data(available_bytes)
				if data[0] == OK:
					var received_message = data[1].get_string_from_utf8()
					return received_message
				else:
					print("[ERROR] Failed to read data from client")
		else:
			print("[ERROR] Client disconnected")
			peer_connections.remove(peer_index)
	else:
		print("[ERROR] Invalid peer index")
	return null

func _process(_delta):
	if tcp_server.is_listening():
		# Check for new connections
		if tcp_server.is_connection_available():
			Engine.time_scale = 10
			var new_peer = tcp_server.take_connection()
			peer_connections.append(new_peer)
			print("[INFO] New client connected")
		
		# Handle existing connections
		for i in range(peer_connections.size()):
			handle_client_request(i)

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

func get_current_game_state():
	if current_level == null:
		for child in get_children():
			if child.name == "level":
				current_level = child
	var data = extract_state_from_node(current_level)
	return JSON.print(data)

func extract_state_from_node(node):
	var bullet_data = []
	for bullet in node.bullets:
		if not is_instance_valid(bullet):
			continue
		bullet_data.append({
			"position" : [bullet.position.x, bullet.position.y],
			"direction" : bullet.get_rotation(),
			"type" : bullet.bullet_type
		 })
	
	var door_data = []
	for door in node.doors:
		if not is_instance_valid(door):
			continue
		var w = door.interactor.get_child(0).shape.get_extents().x
		var h = door.interactor.get_child(0).shape.get_extents().y
		door_data.append(
			[
				door.interactor.global_position.x - w/2,
				door.interactor.global_position.y - h/2,
				door.interactor.global_position.x + w/2,
				door.interactor.global_position.y + h/2,
			]
			# x_1, y_1, x_2, y_2
		)
	var backdoor_data = null
	if node.backdoor:
		var backdoor = node.backdoor
		var w = backdoor.interactor.get_child(0).shape.get_extents().x
		var h = backdoor.interactor.get_child(0).shape.get_extents().y
		backdoor_data =  [
					backdoor.interactor.global_position.x - w/2,
					backdoor.interactor.global_position.y - h/2,
					backdoor.interactor.global_position.x + w/2,
					backdoor.interactor.global_position.y + h/2,
				]
				# x_1, y_1, x_2, y_2
	var enemy_data = []
	var rewards = node.hero.calculate_net_reward()
	if node.current_enemies == 0:
		print("finish")
	var gun_reward = rewards[1] + int(node.current_enemies == 0) * 5
	var hero_reward = rewards[0] + int(node.current_enemies == 0) * 5
	var dead_enemies = 0
	if previous_enemies > 0 and previous_enemies > len(node.enemies):
		dead_enemies = previous_enemies - len(node.enemies)
		gun_reward += dead_enemies*2
		print("dead enemy")
	previous_enemies = len(node.enemies)
	for enemy in node.enemies:
		if enemy.shot:
			print("shot enemy")
			enemy.shot = false
			gun_reward += 1
		enemy_data.append({
			"position" : [enemy.global_position.x, enemy.global_position.y],
			"health" : enemy.health,
			"direction" : enemy.bot_direction.angle(),
			"type" : enemy.enemy_type
		})
	var next_state_data = {
		"hero_reward" : hero_reward,
		"gun_reward" : rewards[1],
		"terminated" : node.hero.terminated,
		"hero" : {
			"position": [node.hero.position.x, node.hero.position.y],
			"health" : node.hero.health,
			"phase_cooldown" : 0.0, #TODO: check if phase is ready
			"ability_cooldown" : 0.0, #TODO: check if ability is ready
			"shoot_cooldown" : 0.0 #TODO: check if ability is ready
		},
		"bullets" : bullet_data,
		"doors" : door_data,
		"enemy" : enemy_data,
		"backdoor" : backdoor_data,
		"walls" : []
	}
	if node.hero.terminated:
		var level = current_level
		if level != null:
			level.cleanup()			
			remove_child(level)
			level.queue_free()
		level = load("res://rooms/tutorial/startingRoom.tscn").instance()
		level.position = Vector2.ZERO
		current_level = level
		add_child(level)
	return next_state_data

func execute_actions(response):
	var parse_result = JSON.parse(response)
	if parse_result.error == OK:
		var actions = parse_result.result
		reset_hero()
		move_hero(actions[0])
		shoot_hero(actions[1])

func reset_hero():
	current_level.hero.agent = true
	current_level.hero.input_vector = Vector2.ZERO
	current_level.hero.agent_direction_vector = Vector2.ZERO

func move_hero(action):
	if action == 1:
		current_level.hero.input_vector = Vector2.UP
	if action == 2:
		current_level.hero.input_vector = Vector2.RIGHT
	if action == 3:
		current_level.hero.input_vector = Vector2.DOWN
	if action == 4:
		current_level.hero.input_vector = Vector2.LEFT
	
	if action == 5:
		current_level.hero.input_vector = Vector2.RIGHT+Vector2.UP
	if action == 6:
		current_level.hero.input_vector = Vector2.RIGHT+Vector2.DOWN
	if action == 7:
		current_level.hero.input_vector = Vector2.LEFT+Vector2.DOWN
	if action == 8:
		current_level.hero.input_vector = Vector2.LEFT+Vector2.UP

func shoot_hero(action):
	if action == 1:
		current_level.hero.agent_direction_vector = Vector2.UP
	if action == 2:
		current_level.hero.agent_direction_vector = Vector2.RIGHT
	if action == 3:
		current_level.hero.agent_direction_vector = Vector2.DOWN
	if action == 4:
		current_level.hero.agent_direction_vector = Vector2.LEFT
	
	if action == 5:
		current_level.hero.agent_direction_vector = Vector2.RIGHT+Vector2.UP
	if action == 6:
		current_level.hero.agent_direction_vector = Vector2.RIGHT+Vector2.DOWN
	if action == 7:
		current_level.hero.agent_direction_vector = Vector2.LEFT+Vector2.DOWN
	if action == 8:
		current_level.hero.agent_direction_vector = Vector2.LEFT+Vector2.UP
