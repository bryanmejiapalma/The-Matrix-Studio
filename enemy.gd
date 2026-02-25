extends CharacterBody2D

const SPEED = 120.0        
const CHASE_SPEED = 200.0  
const STOP_DISTANCE = 35.0 
const DETECTION_RANGE = 400.0
const DAMAGE_AMOUNT = 34 # 3 hits to kill (100 -> 66 -> 32 -> 0)

var target_player = null
var wander_direction = Vector2.RIGHT
var wander_timer = 0.0

func _physics_process(delta: float) -> void:
	check_for_player()

	if target_player and not target_player.is_dead:
		var target_pos = target_player.global_position
		var direction = global_position.direction_to(target_pos)
		var distance = global_position.distance_to(target_pos)
		
		look_at(target_pos)
		
		if distance > STOP_DISTANCE:
			velocity = direction * CHASE_SPEED
		else:
			velocity = Vector2.ZERO
			# DEAL DAMAGE
			if target_player.has_method("take_damage"):
				target_player.take_damage(DAMAGE_AMOUNT)
	else:
		patrol_behavior(delta)
		
	move_and_slide()

func check_for_player():
	# Make sure your Player node is actually named "Player" in the scene tree
	var player = get_tree().root.find_child("Player", true, false)
	if player:
		var dist = global_position.distance_to(player.global_position)
		if dist < DETECTION_RANGE:
			target_player = player
		else:
			target_player = null

func patrol_behavior(delta):
	wander_timer -= delta
	if wander_timer <= 0:
		wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		wander_timer = 2.0
	velocity = wander_direction * SPEED
	rotation = velocity.angle()
