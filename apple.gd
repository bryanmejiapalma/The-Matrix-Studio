extends Area2D

@export var heal_amount = 20

func _on_body_entered(body):
# Check if the thing that touched the apple is the Player
	if body.has_method("heal"):
		body.heal(heal_amount)
	queue_free() # Remove the apple from the scene
