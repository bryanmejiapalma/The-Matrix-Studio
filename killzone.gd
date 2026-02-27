extends Area2D

@onready var timer: Timer = $Timer

func _on_body_entered(body: Node2D) -> void:
	# 1. Check if it's the player
	if body is Player and not body.is_dead:
		
		# 2. Damage the player
		body.take_damage(34)
		
		# --- NEW: STUN THE ENEMY ---
		# Get the Enemy (the parent of this Killzone) and call its stun function
		var enemy = get_parent()
		if enemy.has_method("stun_enemy"):
			enemy.stun_enemy()
		
		# 3. Death Sequence
		if body.health <= 0:
			print("Player has died!")
			Engine.time_scale = 0.5 
			timer.start() 
	
func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0 
	get_tree().reload_current_scene()
