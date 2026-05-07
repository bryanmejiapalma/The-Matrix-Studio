extends Area2D

# Variables to track the player's status
var player_in_zone = false
var is_occupied = false

func _ready():
	# Connect detection signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# CRITICAL: This node MUST stay active to listen for the 'Exit' command
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		player_in_zone = true

func _on_body_exited(body: Node2D):
	# Only set to false if we aren't currently hiding inside
	# This prevents getting 'stuck' if the physics engine disables the player
	if body.is_in_group("player") and not is_occupied:
		player_in_zone = false

func _input(_event: InputEvent):
	# Check if the 'interact' key (E) was pressed
	if Input.is_action_just_pressed("interact"):
		# Allow interaction if the player is nearby OR already inside
		if player_in_zone or is_occupied:
			if not is_occupied:
				enter_locker()
			else:
				exit_locker()

func enter_locker():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		is_occupied = true
		player.is_hidden = true  # Enemies will now ignore the player
		
		# Visuals: Hide the player and snap them to the locker center
		player.modulate.a = 0.0 
		player.global_position = global_position 
		
		# Freeze the player script (movement/sprint/etc)
		player.process_mode = Node.PROCESS_MODE_DISABLED
		print("Player HIDDEN inside locker.")

func exit_locker():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		is_occupied = false
		player.is_hidden = false # Enemies can see the player again
		
		# Visuals: Make player visible and full opacity
		player.modulate.a = 1.0
		
		# Re-enable the player script so they can move again
		player.process_mode = Node.PROCESS_MODE_INHERIT
		print("Player EXITED the locker.")
