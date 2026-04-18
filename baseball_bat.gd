extends Area2D

@onready var shape = $CollisionShape2D

# Variables for state
var is_held = false
var player_in_range = null 
var can_swing = true        
var is_swinging = false     

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	collision_mask = 1 # Initial: Look for Player

func _process(_delta: float) -> void:
	# Check for Interact key
	if Input.is_action_just_pressed("interact"):
		if not is_held and player_in_range != null:
			pick_up(player_in_range)
		elif is_held:
			drop_bat()
	
	# --- MOUSE TRACKING ---
	# Only rotate to follow mouse if held and not currently in the middle of a swing animation
	if is_held and not is_swinging:
		look_at(get_global_mouse_position())
	
	# Swing logic
	if is_held and can_swing:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			swing()

func _on_body_entered(body: Node2D) -> void:
	if not is_held and body.name == "Player":
		player_in_range = body
	# Only hit enemies if we are actually swinging
	elif is_held and is_swinging and body.has_method("stun_enemy"):
		body.stun_enemy()

func _on_body_exited(body: Node2D) -> void:
	if body == player_in_range:
		player_in_range = null

func pick_up(player_node: Node2D) -> void:
	is_held = true
	player_in_range = null
	
	# --- INVENTORY LOGIC ---
	var inv = get_tree().current_scene.find_child("Inventory", true)
	if inv:
		if has_node("%BatSprite2D"):
			var bat_tex = %BatSprite2D.texture 
			inv.add_item(bat_tex)
		else:
			print("no bat sprite found")
	
	# Move from World to Player's HoldPosition
	if get_parent():
		get_parent().remove_child(self)
	
	# Try to find the HoldPosition marker specifically, otherwise just attach to player
	var hold_pos = player_node.find_child("HoldPosition")
	if hold_pos:
		hold_pos.add_child(self)
	else:
		player_node.add_child(self)
	
	position = Vector2.ZERO # Center it on the hand/marker
	collision_mask = 2 # Look for Enemies (Layer 2)

func drop_bat() -> void:
	is_held = false
	
	# --- CLEAR INVENTORY ---
	var player = get_parent()
	var inv = get_tree().current_scene.find_child("Inventory", true)
	if player and inv:
		inv.remove_item_by_name("bat-export")

	# Move from Player back to the World
	var level = get_tree().current_scene
	if get_parent():
		get_parent().remove_child(self)
	level.add_child(self)
	
	global_position = player.global_position + Vector2(0, 5)
	rotation_degrees = 0 # Reset rotation when on ground
	collision_mask = 1 # Look for Player again
	shape.disabled = false
	modulate.a = 1.0
	can_swing = true

func swing() -> void:
	can_swing = false
	is_swinging = true
	
	# 1. Capture where we are pointing at the start of the click
	var start_rot = rotation_degrees
	var end_rot = start_rot + 90 # The "hit" arc
	
	var tween = create_tween()
	# Fast swing forward
	tween.tween_property(self, "rotation_degrees", end_rot, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# Smooth return to original mouse direction
	tween.tween_property(self, "rotation_degrees", start_rot, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	# Give a tiny window where 'is_swinging' is true so collision registers
	await get_tree().create_timer(0.15).timeout
	is_swinging = false  

	# Attack cooldown visuals
	shape.set_deferred("disabled", true)
	modulate.a = 0.3 
	
	# Re-enable after cooldown (Changed to 1.0s for better feel, change to 4.0s if desired)
	await get_tree().create_timer(1.0).timeout
	
	if is_held:
		shape.set_deferred("disabled", false)
		modulate.a = 1.0 
		can_swing = true
