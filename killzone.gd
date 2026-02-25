extends Area2D

@onready var timer: Timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	# 1. Check if it's the player and they aren't dead
	if body.has_method("take_damage") and not body.is_dead:
		
		# 2. Tell the player to take 34 damage
		body.take_damage(34)
		
		# 3. Only trigger the "Death Sequence" if health actually hit 0
		if body.health <= 0:
			print("Player has died after 3 hits!")
			Engine.time_scale = 0.5 # Slow motion effect
			timer.start() # Starts the timer to reload the scene
	
func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0 # Reset speed
	get_tree().reload_current_scene() # Restart level
