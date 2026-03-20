extends CharacterBody2D

@export var speed = 50

var direction = Vector2.ZERO
var change_time = 0

func _ready():
	randomize()
	pick_direction()

func _process(delta):
	change_time -= delta

	# Rotar el raycast hacia donde va el ratón
	if direction != Vector2.ZERO:
		$RayCast2D.target_position = direction * 20

	# Si detecta pared → cambia dirección
	if $RayCast2D.is_colliding():
		pick_direction()

	# Cambiar dirección cada cierto tiempo
	if change_time <= 0:
		pick_direction()

	velocity = direction * speed
	move_and_slide()

func pick_direction():
	direction = Vector2(
		randf_range(-1, 1),
		randf_range(-1, 1)
	).normalized()

	change_time = randf_range(1, 3)
