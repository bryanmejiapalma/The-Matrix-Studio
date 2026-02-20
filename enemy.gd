extends CharacterBody2D

const SPEED = 200.0
# Adjust this to stop the "shaking" when the enemy touches the player
const STOP_DISTANCE = 20.0 

func _physics_process(_delta: float) -> void:
	# 1. Find the player node (Assumes your player node is named "Player")
	var player = get_tree().root.find_child("Player", true, false)
	
	if player:
		var target_pos = player.global_position
		var direction = global_position.direction_to(target_pos)
		var distance = global_position.distance_to(target_pos)
		
		# 2. Face the player
		look_at(target_pos)
		
		# 3. Move if outside the stop distance
		if distance > STOP_DISTANCE:
			velocity = direction * SPEED
		else:
			velocity = Vector2.ZERO
	else:
		# If the player is dead or missing, stop moving
		velocity = Vector2.ZERO
		
	move_and_slide()
	
