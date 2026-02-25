extends CharacterBody2D

const SPEED = 120.0        # Patrol speed
const CHASE_SPEED = 200.0  # Speed up when chasing
const STOP_DISTANCE = 20.0 
const DETECTION_RANGE = 400.0

var target_player = null
var wander_direction = Vector2.RIGHT
var wander_timer = 0.0

func _physics_process(delta: float) -> void:
	# 1. Look for the player
	check_for_player()

	if target_player:
		# --- CHASE LOGIC (Your existing code) ---
		var target_pos = target_player.global_position
		var direction = global_position.direction_to(target_pos)
		var distance = global_position.distance_to(target_pos)
		
		look_at(target_pos)
		
		if distance > STOP_DISTANCE:
			velocity = direction * CHASE_SPEED
		else:
			velocity = Vector2.ZERO
	else:
		# --- PATROL LOGIC (New) ---
		patrol_behavior(delta)
		
	move_and_slide()

func check_for_player():
	var player = get_tree().root.find_child("Player", true, false)
	if player:
		var dist = global_position.distance_to(player.global_position)
		# Only "notice" the player if they are within range
		if dist < DETECTION_RANGE:
			target_player = player
		else:
			target_player = null

func patrol_behavior(delta):
	wander_timer -= delta
	if wander_timer <= 0:
		# Pick a new random direction every 2 seconds
		wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		wander_timer = 2.0
		
	velocity = wander_direction * SPEED
	# Optional: Make the enemy look where he's wandering
	rotation = velocity.angle()
