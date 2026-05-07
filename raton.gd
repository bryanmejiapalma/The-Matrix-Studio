extends CharacterBody2D

@export var walk_speed = 50
@export var run_speed = 120
@export var detection_range = 150 # How close the player gets before the rat runs

var direction = Vector2.ZERO
var change_time = 0
var is_panicked = false

@onready var sprite = $Sprite2D
@onready var ray = $RayCast2D

# To find the player easily
var player = null

func _ready():
	randomize()
	pick_direction()
	# Find the player in the scene
	player = get_tree().get_first_node_in_group("player")

func _process(delta):
	if not player:
		# Try to find player again if not found at start
		player = get_tree().get_first_node_in_group("player")
		return

	# --- DETECTION LOGIC ---
	var distance_to_player = global_position.distance_to(player.global_position)
	
	if distance_to_player < detection_range:
		run_away_from_player()
	else:
		wander_logic(delta)

	# --- VISUALS ---
	if direction.x > 0:
		sprite.flip_h = true # Face Right
	elif direction.x < 0:
		sprite.flip_h = false # Face Left

	velocity = direction * (run_speed if is_panicked else walk_speed)
	move_and_slide()

func wander_logic(delta):
	is_panicked = false
	change_time -= delta
	
	# Update Raycast to look for walls
	if direction != Vector2.ZERO:
		ray.target_position = direction * 20

	if ray.is_colliding() or change_time <= 0:
		pick_direction()

func run_away_from_player():
	is_panicked = true
	# Calculate direction AWAY from player
	# (Rat Position - Player Position) gives a vector pointing away
	direction = (global_position - player.global_position).normalized()
	
	# If the rat hits a wall while running, try to slide along it
	if ray.is_colliding():
		pick_direction() # Pick a new random direction to avoid getting stuck

func pick_direction():
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	change_time = randf_range(1, 4)
