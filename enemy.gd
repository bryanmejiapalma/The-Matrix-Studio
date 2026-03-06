extends CharacterBody2D

const SPEED = 120.0        
const CHASE_SPEED = 200.0  
const STOP_DISTANCE = 115.0 
const DETECTION_RANGE = 400.0
const DAMAGE_AMOUNT = 34 

var target_player = null
var wander_direction = Vector2.RIGHT
var wander_timer = 0.0
var is_stunned: bool = false

func _ready():
	find_player_in_scene()

func _physics_process(delta: float) -> void:
	# If stunned, freeze completely
	if is_stunned:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if is_instance_valid(target_player) and not target_player.is_dead:
		var target_pos = target_player.global_position
		var dist = global_position.distance_to(target_pos)
		if dist < DETECTION_RANGE:
			look_at(target_pos)
			
			if dist > STOP_DISTANCE:
				velocity = global_position.direction_to(target_pos) * CHASE_SPEED
			else:
				velocity = Vector2.ZERO
				# HIT LOGIC
				if target_player.can_take_damage:
					target_player.take_damage(DAMAGE_AMOUNT) # Hits player
					stun_enemy()                            # Enemy stuns itself
				else:
					print("player cannot take damage")
		else:
			target_player = null 
	else:
		find_player_in_scene() 
		patrol_behavior(delta)
		
	move_and_slide()

func stun_enemy():
	print("stunned")
	if is_stunned: return 
	is_stunned = true
	modulate = Color.YELLOW 
	
	# Freeze for 2 seconds
	await get_tree().create_timer(2.0).timeout
	
	is_stunned = false
	modulate = Color.WHITE 

func find_player_in_scene():
	var p = get_tree().root.find_child("Player", true, false)
	if p is CharacterBody2D:
		target_player = p

func patrol_behavior(delta):
	wander_timer -= delta
	if wander_timer <= 0:
		wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		wander_timer = 2.0
	velocity = wander_direction * SPEED
	if velocity.length() > 0:
		rotation = velocity.angle()


func _on_hitbox_body_entered(body: Node2D) -> void:
	if(body.name == "Player"):
		pass
	pass # Replace with function body.
