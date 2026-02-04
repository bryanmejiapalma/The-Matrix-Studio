extends CharacterBody2D

<<<<<<< Updated upstream
const WALK_SPEED = 300
const BOOST_SPEED = 600

# Gravity from project settings

=======
var max_speed := boost_speed
var boost_speed := 1000
var SPEED := 150.0
var current_speed := SPEED
var sprint_multiplier = 1.6
>>>>>>> Stashed changes

func _physics_process(delta: float) -> void:
	# Apply gravity
# Add the gravity. 

<<<<<<< Updated upstream
=======
	# Handle jump.
>>>>>>> Stashed changes

	var vertical_input := Input.get_axis("ui_down", "ui_up")

<<<<<<< Updated upstream
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
=======
	if  Input.is_action_just_pressed("boost"):
		current_speed *=  sprint_multiplier
	
>>>>>>> Stashed changes
	move_and_slide()
