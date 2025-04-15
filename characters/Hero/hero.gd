extends KinematicBody2D

onready var label = $Label
# constants
const MAX_HEALTH = 10
const MAX_ITEMS = 3

const DEFAULT_DODGE = preload("res://abilities/3/phase/phase.tscn")
const DEFAULT_ACTIVE = preload("res://abilities/3/flares/flares.tscn")
const DEFAULT_PASSIVE = preload("res://passive/passive.tscn")

onready var ROOT_NODE = get_parent().get_parent().get_parent()

export var accelration = 2000
export var FRICTION =1000
export var move_speed = 300

# the velocity of the player
export var player_velocity = Vector2.ZERO
export var input_vector = Vector2.ZERO

# the impulse exerted on contact
export (int, 0, 200) var impulse_exerted = 100

onready var AnimationPlayer = $AnimationPlayer
onready var AnimationTree = $AnimationTree
onready var AnimationState = AnimationTree.get("parameters/playback")
onready var hitbox = $hitbox

# gun init
var hostile_group = "hostile"
var friendly_group = "hero"
var mouse_left_down = false

export var health = 10
const PUSH_FORCE = 175

var current_state = State.READY
enum State {READY,MUTED,DISARMED,STUNNED}

var modifiers = []

#inventory
onready var weapon = $weapon

var dodge
var passive
var active
var ultimate

var items = []

var progress_bars = []
var timers = []

var agent = false
var agent_direction_vector = Vector2.ZERO

# HERO_REWARD VALUE #
const INCREASING_HEALTH_REWARD = 3
const LINE_OF_SIGHT_REWARD = 2
const OPENING_DOOR_REWARD = 2
const ROOM_CLEAR_REWARD = 7.5
const DECREASING_HEALTH_PUNISHMENT = -2.5
const DYING_PUNISHMENT = -10
const LIVING_PUNISHMENT = -0.15
# GUN_REWARD VALUES #
const SHOOTING_ENEMY_REWARD = 1
const KILLING_ENEMY_REWARD = 2
######################

var hero_reward = 0
var gun_reward = 0

onready var rays = [
	$line_of_sight/direction_0,
	$line_of_sight/direction_1,
	$line_of_sight/direction_2,
	$line_of_sight/direction_3,
	$line_of_sight/direction_4,
	$line_of_sight/direction_5,
	$line_of_sight/direction_6,
	$line_of_sight/direction_7,
]

var terminated = false

func _ready():
	health = 10
	update_health_UI()
	if get_node("passive") == null:
		passive = DEFAULT_PASSIVE.instance()
		passive.user = self
		passive.name = "passive"
		add_child(passive)
	if get_node("dodge") == null:
		dodge = DEFAULT_DODGE.instance()
		dodge.user = self
		dodge.name = "dodge"
		add_child(dodge)
		
	if get_node("active") == null:
		active = DEFAULT_ACTIVE.instance()
		active.user = self
		active.name = "active"
		add_child(active)
	
	$weapon.hostile_group = hostile_group
	$weapon.friendly_group = friendly_group
	$weapon.follow = null

func _process(_delta):
	hero_reward = LIVING_PUNISHMENT
	if health < 1 :
		die()
	elif health > MAX_HEALTH:
		health = MAX_HEALTH
	
	manage_shooting()
	if agent or true:
		hero_reward += raycast_check()
	
	for itr in range(progress_bars.size()):
		var progress_bar = progress_bars[itr]
		var timer = timers[itr]
		
		display_cooldown_progress(progress_bar,timer)
		
		if timer.is_stopped():
			progress_bars.remove(itr)
			timers.remove(itr)
			
			progress_bar.hide()
			break

func manage_shooting():
	set_attack_to_white()
	if current_state == State.DISARMED:
		return
	if agent:
		show_agent_attack_UI(agent_direction_vector)		
		if agent_direction_vector != Vector2.ZERO:
			shoot(agent_direction_vector.angle())
		return
	if not(Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_DOWN)):
		return
	var direction_vector = Vector2.ZERO
	
	if Input.is_key_pressed(KEY_RIGHT):
		direction_vector += Vector2(1, 0)
	if Input.is_key_pressed(KEY_LEFT):
		direction_vector += Vector2(-1,0)
	if Input.is_key_pressed(KEY_UP):
		direction_vector += Vector2(0,-1)
	if Input.is_key_pressed(KEY_DOWN):
		direction_vector += Vector2(0,1)
		
	show_agent_attack_UI(direction_vector)
	shoot(direction_vector.angle())

func _physics_process(delta):
	get_player_velocity(delta)
	player_velocity = move_and_slide(player_velocity,Vector2.UP,false, 4, PI/4, false)
	
	apply_impulse()

func get_player_velocity (delta):
	if not agent:
		get_input_vector()
	input_vector = input_vector.normalized()
	show_agent_movement_UI(input_vector)

	# decide_and_play_animation(input_vector)
	
	if input_vector != Vector2.ZERO:
		
		AnimationTree.set("parameters/Idle/blend_position",input_vector)
		AnimationTree.set("parameters/Run/blend_position",input_vector)
		AnimationState.travel("Run")
		
		player_velocity += input_vector * accelration * delta
		player_velocity = player_velocity.clamped(move_speed)
	else:
		AnimationState.travel("Idle")
		
		player_velocity = player_velocity.move_toward(Vector2.ZERO,FRICTION * delta)
		
	input_vector = Vector2.ZERO

func apply_impulse():
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.is_in_group("walls"):
			collision.collider.apply_central_impulse(-collision.normal * impulse_exerted)

func get_input_vector ():
	var vel = Vector2.ZERO	
	if current_state != State.STUNNED:
		if Input.is_key_pressed(KEY_W):
			vel += Vector2.UP
		if Input.is_key_pressed(KEY_A):
			vel += Vector2.LEFT
		if Input.is_key_pressed(KEY_S):
			vel += Vector2.DOWN
		if Input.is_key_pressed(KEY_D):
			vel += Vector2.RIGHT
	
	input_vector = vel

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			var character: String = OS.get_scancode_string(event.scancode)
	
	if current_state != State.STUNNED:
		if current_state != State.MUTED:
			handle_items_and_abilities()

func handle_items_and_abilities():
	if Input.is_key_pressed(KEY_Q):
		if dodge.ready:
			var cooldown_timer = dodge.use()
			update_ability_cooldown("dodge",cooldown_timer)
	
	if Input.is_key_pressed(KEY_R):
		if active.ready:
			var cooldown_timer = active.use()
			update_ability_cooldown("active",cooldown_timer)
	

# give passive path
func replace_passive(new_passive):
	passive.on_remove()
	passive = load(new_passive).instance()

func shoot(direction: float):
	if ($weapon.state == $weapon.State.READY):
		$weapon.shoot_at(direction)
		

func deal_damage (dmg) :
	dmg = passive.on_get_hit(dmg)
	health -= dmg
	hero_reward += DECREASING_HEALTH_PUNISHMENT * dmg
	if health < 1 :
		hero_reward += DYING_PUNISHMENT * dmg
		die()
	else:
		for bullet in get_parent().get_parent().bullets:
			if bullet != null and is_instance_valid(bullet) and bullet is Area2D:
				bullet.die()
	update_health_UI()

func heal(heal):
	health += heal
	if health > MAX_HEALTH:
		health = MAX_HEALTH
		heal = 0
	
	if heal < 0:
		hero_reward += INCREASING_HEALTH_REWARD * heal
	elif heal > 0:
		hero_reward += DECREASING_HEALTH_PUNISHMENT * heal
	
	update_health_UI()
	

func update_ability_cooldown(type,timer):
	var progress_bar = ROOT_NODE.get_node("overlay/MarginContainer/Panel/abilities/"+type+"/TextureProgress")
	progress_bar.show()
	progress_bar.value = 100
	
	progress_bars.append(progress_bar)
	timers.append(timer)

func display_cooldown_progress(progress_bar, timer):
	progress_bar.value = int(round((100/timer.wait_time) * timer.time_left))
	progress_bar.get_node("Label").text = str(int(round(timer.time_left)))


func update_health_UI ():
	var node = ROOT_NODE
	
	var health_nodes = node.get_node("overlay/MarginContainer/Panel/health")
	
	for h in range(0,max(health, 0)):
		health_nodes.get_child(h).texture = load("res://sprites/UI/health.png")
		if h == 9:
			health_nodes.get_child(9).texture = load("res://sprites/UI/health_end.png")
	for h in range(max(health, 0),MAX_HEALTH):
		health_nodes.get_child(h).texture = load("res://sprites/UI/no_health.png")
		if h == 9:
			health_nodes.get_child(9).texture = load("res://sprites/UI/no_health_end.png")

func die():
	terminated = true
	#get_tree().change_scene("res://main.tscn")

func calculate_net_reward():
	return [hero_reward, gun_reward]
	
func show_agent_attack_UI(attack_direction):
	# Reset all directions to white first
	set_attack_to_white()
	
	# Right (0)
	if attack_direction.x == 1 and attack_direction.y == 0:
		$attack/direction_0.modulate = Color(1,0,0)
	# Up-Right (1)
	elif attack_direction.x == 1 and attack_direction.y == -1:
		$attack/direction_1.modulate = Color(1,0,0)
	# Up (2)
	elif attack_direction.x == 0 and attack_direction.y == -1:
		$attack/direction_2.modulate = Color(1,0,0)
	# Up-Left (3)
	elif attack_direction.x == -1 and attack_direction.y == -1:
		$attack/direction_3.modulate = Color(1,0,0)
	# Left (4)
	elif attack_direction.x == -1 and attack_direction.y == 0:
		$attack/direction_4.modulate = Color(1,0,0)
	# Down-Left (5)
	elif attack_direction.x == -1 and attack_direction.y == 1:
		$attack/direction_5.modulate = Color(1,0,0)
	# Down (6)
	elif attack_direction.x == 0 and attack_direction.y == 1:
		$attack/direction_6.modulate = Color(1,0,0)
	# Down-Right (7)
	elif attack_direction.x == 1 and attack_direction.y == 1:
		$attack/direction_7.modulate = Color(1,0,0)

func set_attack_to_white():
	for i in range(8):
		get_node("attack/direction_" + str(i)).modulate = Color(1,1,1,0)

func show_agent_movement_UI(movement_direction):
	# Reset all directions to white first
	set_movement_to_white()
	if player_velocity == Vector2.ZERO:
		$movement/direction_8.modulate = Color(1,0,0)
		return
	
	# Convert the direction to an angle in radians
	var angle = movement_direction.angle()
	
	# Map the angle to one of the 8 directions (0-7)
	# Each direction covers 45 degrees (PI/4 radians)
	var direction_index = int(round(8 * angle / (2 * PI) + 8)) % 8
	
	# Right (0): angle near 0 or 2π
	if direction_index == 0:
		$movement/direction_0.modulate = Color(1,0,0)
	# Up-Right (1): angle near π/4
	elif direction_index == 7:
		$movement/direction_1.modulate = Color(1,0,0)
	# Up (2): angle near π/2
	elif direction_index == 6:
		$movement/direction_2.modulate = Color(1,0,0)
	# Up-Left (3): angle near 3π/4
	elif direction_index == 5:
		$movement/direction_3.modulate = Color(1,0,0)
	# Left (4): angle near π
	elif direction_index == 4:
		$movement/direction_4.modulate = Color(1,0,0)
	# Down-Left (5): angle near 5π/4
	elif direction_index == 3:
		$movement/direction_5.modulate = Color(1,0,0)
	# Down (6): angle near 3π/2
	elif direction_index == 2:
		$movement/direction_6.modulate = Color(1,0,0)
	# Down-Right (7): angle near 7π/4
	elif direction_index == 1:
		$movement/direction_7.modulate = Color(1,0,0)
	else:
		$movement/direction_8.modulate = Color(1,0,0)

func set_movement_to_white():
	for i in range(9):
		get_node("movement/direction_" + str(i)).modulate = Color(1,1,1,0)

func raycast_check():
	var line_of_sights = 0
	
	var eligible_rays = Vector2.ZERO
	for ray in rays:
		if ray.get_collider() != null:
			line_of_sights += 1
	
	
	return line_of_sights * LINE_OF_SIGHT_REWARD
