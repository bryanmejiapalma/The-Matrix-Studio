extends Area2D

func _ready() -> void:
	# Connect the signal so it detects when it hits the enemy
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Check if the thing we hit is an Enemy
	# This works because your enemy script has the 'stun_enemy' function
	if body.has_method("stun_enemy"):
		body.stun_enemy()
		print("Bonk! Enemy stunned.")
