extends Node

# Preload your player scene so the manager can "spawn" it
var player_scene = preload("res://Player.tscn") 

func respawn_player():
	# 1. Wait a moment so the death isn't instant
	await get_tree().create_timer(1.0).timeout
	
	# 2. Create the new player instance
	var new_player = player_scene.instantiate()
	
	# 3. Set the starting position (adjust these numbers to your start point)
	new_player.position = Vector2(100, 100)
	
	# 4. Add the new player back into the world
	get_tree().current_scene.add_child(new_player)
