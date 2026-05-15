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
	if Input.is_action_just_pressed("interact"):
		if not is_held and player_in_range != null:
			pick_up(player_in_range)
		elif is_held:
			drop_bat()
	
	if is_held and not is_swinging:
		look_at(get_global_mouse_position())
	
	if is_held and can_swing:
		if Input.is_action_just_pressed("hit"):
			swing()

func _on_body_entered(body: Node2D) -> void:
	if not is_held and body.name == "Player":
		player_in_range = body
	
	# --- FIX FOR SPIDERS ---
	elif is_held and is_swinging:
		# 1. Check for Spiders (they use take_damage)
		if body.is_in_group("enemy") and body.has_method("take_damage"):
			body.take_damage(20) # Deals 20 damage (kills spider in 1 hit)
			print("Hit Spider!")
		
		# 2. Check for your original Enemy (they use stun_enemy)
		elif body.has_method("stun_enemy"):
			body.stun_enemy()
			print("Stunned Shadow Enemy!")

func _on_body_exited(body: Node2D) -> void:
	if body == player_in_range:
		player_in_range = null

func pick_up(player_node: Node2D) -> void:
	is_held = true
	player_in_range = null
	
	var inv = get_tree().current_scene.find_child("Inventory", true)
	if inv:
		if has_node("%BatSprite2D"):
			var bat_tex = %BatSprite2D.texture 
			inv.add_item(bat_tex)
	
	if get_parent():
		get_parent().remove_child(self)
	
	var hold_pos = player_node.find_child("HoldPosition")
	if hold_pos:
		hold_pos.add_child(self)
	else:
		player_node.add_child(self)
	
	position = Vector2.ZERO 
	# Set collision mask to detect both Layer 1 (World) and Layer 2 (Enemies)
	collision_mask = 3 

func drop_bat() -> void:
	is_held = false
	var player = get_parent()
	var level = get_tree().current_scene
	if get_parent():
		get_parent().remove_child(self)
	level.add_child(self)
	
	global_position = player.global_position + Vector2(0, 5)
	rotation_degrees = 0 
	collision_mask = 1 
	shape.disabled = false
	modulate.a = 1.0
	can_swing = true

func swing() -> void:
	can_swing = false
	is_swinging = true
	
	# Enable collision when the swing begins
	shape.set_deferred("disabled", false)
	
	var start_rot = rotation_degrees
	var end_rot = start_rot + 90 
	
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees", end_rot, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation_degrees", start_rot, 0.1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	await get_tree().create_timer(0.15).timeout
	is_swinging = false  

	# Disable collision during the 1-second cooldown
	shape.set_deferred("disabled", true)
	modulate.a = 0.3 
	
	await get_tree().create_timer(1.0).timeout
	
	if is_held:
		shape.set_deferred("disabled", false)
		modulate.a = 1.0 
		can_swing = true
