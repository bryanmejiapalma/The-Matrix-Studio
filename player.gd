extends CharacterBody2D
class_name Player # Added this so the Killzone can recognize the player

const WALK_SPEED = 300
const BOOST_SPEED = 600

var is_dead: bool = false # Added this variable to fix the error

@onready var sprite_2d: Sprite2D = $Sprite2D 

func _physics_process(_delta: float) -> void:
	if is_dead: return # Stops movement when dying

	var vertical_input := Input.get_axis("ui_up", "ui_down")
	var horizontal_input := Input.get_axis("ui_left", "ui_right")

	# Sprint/Boost Logic
	var current_speed = WALK_SPEED
	if Input.is_action_pressed("boost"):
		current_speed = BOOST_SPEED

	velocity.x = horizontal_input * current_speed
	velocity.y = vertical_input * current_speed

	move_and_slide()

func die():
	is_dead = true
