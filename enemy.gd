extends CharacterBody2D

const SPEED = 120.0        
const CHASE_SPEED = 200.0  
const STOP_DISTANCE = 128.0 
const DETECTION_RANGE = 400.0
const DAMAGE_AMOUNT = 34 

var target_player = null
var wander_direction = Vector2.RIGHT
var wander_timer = 0.0
var is_stunned: bool = false

func _ready():
	# Finds the player by group (standard for Godot projects)
	target_player = get_tree().get_first_node_in_group("player")
	
	if has_node("Killzone"):
		$Killzone.hit_player.connect(stun_enemy)

func _physics_process(delta: float) -> void:
	# 1. If stunned, don't do anything
	if is_stunned:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	check_for_player()

	# --- FIX: Added 'not target_player.is_hidden' ---
	# This makes the enemy stop chasing if you are dead OR hiding in a locker
	if target_player and not target_player.is_dead and not target_player.is_hidden:
		var target_pos = target_player.global_position
		var direction = global_position.direction_to(target_pos)
		var distance = global_position.distance_to(target_pos)
		
		look_at(target_pos)
		
		if distance > STOP_DISTANCE:
			velocity = direction * CHASE_SPEED
		else:
			velocity = Vector2.ZERO
			if target_player.has_method("take_damage"):
				if target_player.can_take_damage:
					target_player.take_damage(DAMAGE_AMOUNT)
					stun_enemy()
	else:
		# If player is hidden or out of range, go back to patrolling
		patrol_behavior(delta)
		
	move_and_slide()

func stun_enemy():
	if is_stunned: return 
	is_stunned = true
	modulate = Color.YELLOW 
	print("Enemy is stunned!")
	
	await get_tree().create_timer(2.0).timeout
	
	is_stunned = false
	modulate = Color.WHITE 

func check_for_player():
	# Improved finding method using the group we set up
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var dist = global_position.distance_to(player.global_position)
		# --- FIX: The enemy only "detects" the player if they aren't hidden ---
		if dist < DETECTION_RANGE and not player.is_hidden:
			target_player = player
		else:
			target_player = null

func patrol_behavior(delta):
	wander_timer -= delta
	if wander_timer <= 0:
		wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		wander_timer = randf_range(1.5, 3.0) # Randomize patrol time for variety
	
	velocity = wander_direction * SPEED
	
	# Smoothly point toward where it's walking
	if velocity.length() > 0:
		rotation = lerp_angle(rotation, velocity.angle(), 10 * delta)

# Triggered when the player touches the enemy's physical hitbox Area2D
func _on_hitbox_body_entered(body: Node2D) -> void:
	# If body is the player and NOT hidden
	if body.is_in_group("player") and not body.is_hidden:
		target_player = body
		if body.has_method("take_damage"):
			body.take_damage(DAMAGE_AMOUNT)
		stun_enemy()

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body == target_player:
		target_player = null
		print("Enemy lost sight of player.")
