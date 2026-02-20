extends CharacterBody2D
class_name Player

const WALK_SPEED = 300
const BOOST_SPEED = 600

var is_dead: bool = false
var health = 100
var max_health = 100

@onready var sprite_2d: Sprite2D = $Sprite2D 
@onready var health_bar = $ProgressBar # Ensure this path is correct in your scene tree

func _ready():
	# This runs once when the game starts
	health = 50 
	health_bar.max_value = max_health
	health_bar.value = health
	print("Game started. Health set to: ", health)

func _physics_process(_delta: float) -> void:
	if is_dead: return 

	var vertical_input := Input.get_axis("ui_up", "ui_down")
	var horizontal_input := Input.get_axis("ui_left", "ui_right")

	var current_speed = WALK_SPEED
	if Input.is_action_pressed("boost"):
		current_speed = BOOST_SPEED

	velocity.x = horizontal_input * current_speed
	velocity.y = vertical_input * current_speed

	move_and_slide()

func die():
	is_dead = true

func heal(amount):
	health += amount
	# Clamp ensures health doesn't go over 100 or below 0
	health = clamp(health, 0, max_health)
	
	# Update the UI
	health_bar.value = health
	print("Healed! Current health: ", health)
