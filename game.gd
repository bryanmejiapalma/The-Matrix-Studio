extends Node

# This script should be attached to your "game" scene root
# Make sure your Player is already placed in the 2D editor 
# OR use the code below to spawn them.

func _ready():
	# Ensure the mouse is captured (good for horror/stealth) 
	# and the game doesn't start with a red screen.
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var vignette = player.get_node_or_null("CanvasLayer/BloodVignette")
		if vignette:
			vignette.modulate.a = 0.0
	
	print("Game Started! Hide and survive.")

func _input(event):
	# If the player presses ESCAPE, go back to the Main Menu
	if event.is_action_pressed("ui_cancel"):
		# Change "MainMenu.tscn" to your actual menu file name
		get_tree().change_scene_to_file("res://MainMenu.tscn")

# If you decide NOT to reload the whole scene on death, 
# you can call this from your Player script instead.
func respawn_player():
	# Preload inside the function to avoid circular dependency errors
	var player_scene = load("res://player.tscn") 
	
	# Wait a moment for the 'game over' feel
	await get_tree().create_timer(1.5).timeout
	
	var new_player = player_scene.instantiate()
	
	# Set this to a safe coordinate on your map (where there are NO walls)
	new_player.position = Vector2(150, 100) 
	
	add_child(new_player)
	print("Player respawned!")
