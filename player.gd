extends CharacterBody2D
class_name Player

const WALK_SPEED = 300
const BOOST_SPEED = 600
const SPRINT_TIME_MAX = 2.5  # Max sprint duration in seconds

var is_dead: bool = false
var health = 100
var max_health = 100
var can_take_damage: bool = true 
var held_item = null 

# --- STAMINA ---
var sprint_stamina: float = SPRINT_TIME_MAX 

@onready var sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar = $ProgressBar
@onready var pickup_zone = $PickupZone 
@onready var hold_position = $HoldPosition 

func _ready():
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = health

func _physics_process(delta: float) -> void:
	if is_dead: return 

	# --- FALL OFF MAP CHECK ---
	if global_position.y > 1000: 
		die()

	var vertical_input := Input.get_axis("ui_up", "ui_down")
	var horizontal_input := Input.get_axis("ui_left", "ui_right")

	# --- SPRINT LOGIC ---
	var current_speed = WALK_SPEED
	
	if Input.is_action_pressed("boost") and sprint_stamina > 0:
		current_speed = BOOST_SPEED
		sprint_stamina -= delta
	else:
		sprint_stamina = move_toward(sprint_stamina, SPRINT_TIME_MAX, delta * 0.5)

	# --- NORMALIZED MOVEMENT (prevents faster diagonal speed) ---
	var input_vector = Vector2(horizontal_input, vertical_input).normalized()
	velocity = input_vector * current_speed

	move_and_slide()

	# --- ANIMATION CALL ---
	update_animation(horizontal_input, vertical_input)

# --- ANIMATION SYSTEM ---
func update_animation(h_input: float, v_input: float):
	if is_dead:
		if sprite_2d.animation != "default":
			sprite_2d.play("default")
		return

	var is_moving = h_input != 0 or v_input != 0
	var is_sprinting = Input.is_action_pressed("boost") and sprint_stamina > 0

	if is_moving:
		# Speed up animation if sprinting
		sprite_2d.speed_scale = 1.5 if is_sprinting else 1.0

		# Direction priority (vertical over horizontal)
		if abs(v_input) > abs(h_input):
			if v_input < 0:
				if sprite_2d.animation != "walk_up":
					sprite_2d.play("walk_up")
			else:
				if sprite_2d.animation != "walk_down":
					sprite_2d.play("walk_down")
		else:
			if sprite_2d.animation != "walk_left_right":
				sprite_2d.play("walk_left_right")
			
			# Flip sprite for left/right
			sprite_2d.flip_h = h_input < 0
	else:
		sprite_2d.speed_scale = 1.0
		if sprite_2d.animation != "default":
			sprite_2d.play("default")

# --- DAMAGE SYSTEM ---
func take_damage(amount: int):
	if is_dead or not can_take_damage: return
	
	health -= amount
	health_bar.value = health
	print("Player Health: ", health)
	
	# --- SCREEN SHAKE TRIGGER ---
	# Checks if the Camera2D exists as a child and calls its shake function
	if has_node("Camera2D"):
		$Camera2D.apply_shake(15.0)
	
	if health <= 0:
		die()
	else:
		trigger_invincibility()

func trigger_invincibility():
	can_take_damage = false
	modulate = Color.RED 
	await get_tree().create_timer(1.0).timeout 
	modulate = Color.WHITE
	can_take_damage = true

func die():
	if is_dead: return
	
	is_dead = true
	# Note: Ensure Camera2D has "Ignore Rotation" enabled in Inspector 
	# so the whole screen doesn't rotate with the player!
	rotation_degrees = 90
	print("Player is down!")

	await get_tree().create_timer(2.0).timeout
	get_tree().reload_current_scene()

# --- PICKUP LOGIC ---
func _input(_event):
	if Input.is_action_just_pressed("interact"):
		if held_item:
			drop_item()
		else:
			pick_up_item()

func pick_up_item():
	var areas = pickup_zone.get_overlapping_areas()
	for area in areas:
		if area.is_in_group("pickable"):
			held_item = area
			held_item.get_parent().remove_child(held_item)
			hold_position.add_child(held_item)
			held_item.position = Vector2.ZERO
			break

func drop_item():
	if held_item:
		var item_to_drop = held_item
		hold_position.remove_child(item_to_drop)
		get_tree().current_scene.add_child(item_to_drop)
		item_to_drop.global_position = global_position
		held_item = null

func heal(val):
	health = clamp(health + val, 0, max_health)
	health_bar.value = health
