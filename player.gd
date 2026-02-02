extends CharacterBody2D

const WALK_SPEED = 300
const BOOST_SPEED = 600

# Gravity from project settings


func _physics_process(delta: float) -> void:
	# Apply gravity
# Add the gravity. 


	var vertical_input := Input.get_axis("ui_down", "ui_up")

	# Horizontal input (left/right)
	var horizontal_input := Input.get_axis("ui_left", "ui_right", )

	# Choose speed: walk or sprint
	var current_speed = WALK_SPEED
	if Input.is_action_pressed("boost"):
		current_speed = BOOST_SPEED


	# Set horizontal velocity
	velocity.x = horizontal_input * current_speed
	velocity.y = vertical_input * current_speed
	# Move the character with collisions
	move_and_slide()
