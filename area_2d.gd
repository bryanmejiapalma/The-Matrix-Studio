extends Area2D

func _on_body_entered(body: Node) -> void:
	# Check if the object entering is named "Player"
	if body.name == "Player":
		body.queue_free() # Deletes the player node
		# Optional: restart the game instead
		# get_tree().reload_current_scene()
