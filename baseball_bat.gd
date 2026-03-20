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
	
	# Swing logic
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
	
	# --- UNIQUE NAME SPRITE LOGIC ---
	# We find the inventory and hand over the texture from the %Unique Sprite
	var inv = get_tree().current_scene.find_child("Inventory", true)
	if inv:
		# IMPORTANT: Change '%Sprite2D' to the exact unique name you gave it
		if has_node("%BatSprite2D"):
			var bat_tex = %BatSprite2D.texture 
			inv.add_item(bat_tex)
		else:
			print("no bat sprite found")
	else:
		print("no inventory found")
	
	# Move from World to Player's hand
	if get_parent():
		get_parent().remove_child(self)
	player_node.add_child(self)
	
	position = Vector2(15, 0) # Position in hand
	rotation_degrees = 0
	collision_mask = 2 # Look for Enemies

func drop_bat() -> void:
	is_held = false
	
	# --- CLEAR INVENTORY BOX ---
	var player = get_parent()
	var inv = get_tree().current_scene.find_child("Inventory", true)
	if player and inv:
		inv.remove_item_by_name("baseball_bat")

	# Move from Player back to the World
	var level = get_tree().current_scene
	player.remove_child(self)
	level.add_child(self)
	
	global_position = player.global_position + Vector2(0, 5)
	collision_mask = 1 # Look for Player again
	shape.disabled = false
	modulate.a = 1.0
	can_swing = true

func swing() -> void:
	can_swing = false
	is_swinging = true
	
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees", 90, 0.1)
	tween.tween_property(self, "rotation_degrees", 0, 0.1)

	await get_tree().create_timer(0.15).timeout
	is_swinging = false  

	# Attack cooldown visual/physics
	shape.set_deferred("disabled", true)
	modulate.a = 0.3 
	
	await get_tree().create_timer(4.0).timeout
	
	if is_held:
		shape.set_deferred("disabled", false)
		modulate.a = 1.0 
		can_swing = true
