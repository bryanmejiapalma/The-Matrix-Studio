extends Area2D

@onready var shape = $CollisionShape2D

var is_held = false
var player_in_range = null 
var can_swing = true        
var is_swinging = false     

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	collision_mask = 1 # Initial: Look for Player

func _process(_delta: float) -> void:
	# Check for "E" press
	if Input.is_action_just_pressed("interact"):
		if not is_held and player_in_range != null:
			pick_up(player_in_range)
		elif is_held:
			drop_bat()
	
	# Swing logic: Left click
	if is_held and can_swing:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			swing()

func _on_body_entered(body: Node2D) -> void:
	if not is_held and body.name == "Player":
		player_in_range = body
	elif is_held and is_swinging and body.has_method("stun_enemy"):
		body.stun_enemy()

func _on_body_exited(body: Node2D) -> void:
	if body == player_in_range:
		player_in_range = null

func pick_up(player_node: Node2D) -> void:
	is_held = true
	player_in_range = null
	
	# Move from Ground to Player
	get_parent().remove_child(self)
	player_node.add_child(self)
	
	position = Vector2(15, 0) # Adjust for hand position
	rotation_degrees = 0
	collision_mask = 2 # Look for Enemies

func drop_bat() -> void:
	is_held = false
	
	# 1. Move from Player back to the Level
	var player = get_parent()
	var level = get_tree().current_scene
	
	player.remove_child(self)
	level.add_child(self)
	
	# 2. Place it at the player's feet
	global_position = player.global_position + Vector2(0, 5)
	
	# 3. Reset masks and visibility
	collision_mask = 1 # Look for Player again
	shape.disabled = false
	modulate.a = 1.0
	can_swing = true
	print("Bat dropped!")

func swing() -> void:
	can_swing = false
	is_swinging = true
	
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees", 90, 0.1)
	tween.tween_property(self, "rotation_degrees", 0, 0.1)

	await get_tree().create_timer(0.15).timeout
	is_swinging = false  

	# Penalty starts
	shape.set_deferred("disabled", true)
	modulate.a = 0.3 
	
	await get_tree().create_timer(4.0).timeout
	
	# Only reset if we are still holding it
	if is_held:
		shape.set_deferred("disabled", false)
		modulate.a = 1.0 
		can_swing = true
