extends CharacterBody2D

const WALK_SPEED = 300
const BOOST_SPEED = 600

@onready var sprite_2d: Sprite2D = %Sprite2D
@onready var timer: Timer = %Timer
@onready var hitbox: Area2D = $Hitbox

func _ready() -> void:
	# This is the 'wire' that detects the hit
	hitbox.body_entered.connect(_on_hitbox_body_entered)

func _on_hitbox_body_entered(body: Node) -> void:
	# DEBUG: This will print the name of EVERYTHING the player touches in the console
	print("Hitbox touched: ", body.name)
	
	# If the object is an Enemy, kill the player
	if "Enemy" in body.name or body.is_in_group("enemies"):
		die()

func die():
	print("Death triggered!")
	# Reloading is better than queue_free() because it resets the game
	get_tree().reload_current_scene.call_deferred()

func _physics_process(delta: float) -> void:
	var vertical_input := Input.get_axis("ui_up", "ui_down") 
	var horizontal_input := Input.get_axis("ui_left", "ui_right")

	var current_speed = WALK_SPEED
	if Input.is_action_pressed("boost"):
		current_speed = BOOST_SPEED

	velocity.x = horizontal_input * current_speed
	velocity.y = vertical_input * current_speed

	if Input.is_action_just_pressed("boost"):
		timer.start()
		
	move_and_slide()
