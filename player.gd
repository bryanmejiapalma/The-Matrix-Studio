extends CharacterBody2D
class_name Player

const WALK_SPEED = 300
const BOOST_SPEED = 600
const SPRINT_TIME_MAX = 2.5 

var is_dead: bool = false
var health = 100
var max_health = 100
var can_take_damage: bool = true 
var held_item = null 

var sprint_stamina: float = SPRINT_TIME_MAX 

@onready var health_bar = $ProgressBar

func _ready():
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = health

func _physics_process(delta: float) -> void:
	if is_dead: return 

	if global_position.y > 1000: 
		die()

	# Movement Input
	var vertical_input := Input.get_axis("ui_up", "ui_down")
	var horizontal_input := Input.get_axis("ui_left", "ui_right")

	# Sprint Logic
	var current_speed = WALK_SPEED
	if Input.is_action_pressed("boost") and sprint_stamina > 0:
		current_speed = BOOST_SPEED
		sprint_stamina -= delta 
	else:
		sprint_stamina = move_toward(sprint_stamina, SPRINT_TIME_MAX, delta * 0.5)

	velocity.x = horizontal_input * current_speed
	velocity.y = vertical_input * current_speed

	move_and_slide()

func take_damage(amount: int):
	if is_dead or not can_take_damage: return
	
	health -= amount
	health_bar.value = health
	
	if health <= 0:
		die()
	else:
		trigger_invincibility()

func trigger_invincibility():
	can_take_damage = false
	modulate = Color.RED # Visual cue for taking damage
	
	# Only protects from damage, does NOT stop movement
	await get_tree().create_timer(1.0).timeout 
	
	modulate = Color.WHITE
	can_take_damage = true

func die():
	if is_dead: return
	is_dead = true
	rotation_degrees = 90
	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()

# ... (Keep your Pickup/Heal logic exactly as it was)
