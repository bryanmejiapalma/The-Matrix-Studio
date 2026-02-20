extends Area2D

@onready var timer: Timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	# This checks if the body has a "die" function and isn't already dead
	if body.has_method("die") and not body.is_dead:
		print("Player has died!")
		Engine.time_scale = 0.5 # Slow motion
		body.die()
		timer.start() # Starts the child Timer node

func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0 # Reset speed
	get_tree().reload_current_scene() # Restart level
