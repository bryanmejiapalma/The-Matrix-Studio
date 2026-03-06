extends Node

# Preload your player scene so the manager can "spawn" it
var player_scene = preload("res://Player.tscn") # Make sure this path is correct!

func respawn_player():
	# 1. Wait a moment so the death isn't instant
	await get_tree().create_timer(1.0).timeout
	
	# 2. Create the new player instance
	var new_player = player_scene.instantiate()
	
	# --- FIX START ---
	# Force the name to be exactly "Player" so the Enemy can find it
	new_player.name = "Player" 
	
	# Add it to the "player" group as a backup
	new_player.add_to_group("player")
	# --- FIX END ---
	
	# 3. Set the starting position
	new_player.position = Vector2(100, 100)
	
	# 4. Add the new player back into the world
	get_tree().current_scene.add_child(new_player)
	
	print("New Player spawned with name: ", new_player.name)
