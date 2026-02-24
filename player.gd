extends CharacterBody2D
class_name Player

const WALK_SPEED = 300
const BOOST_SPEED = 600

var is_dead: bool = false
var health = 100
var max_health = 100
var held_item = null # Keeps track of what we are carrying

@onready var sprite_2d: Sprite2D = $Sprite2D 
@onready var health_bar = $ProgressBar
@onready var pickup_zone = $PickupZone # Ensure this matches your Area2D name
@onready var hold_position = $HoldPosition # Ensure this matches your Marker2D name

func _ready():
	health = 50 
	health_bar.max_value = max_health
	health_bar.value = health

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

func _input(event):
	# Pickup/Drop Logic
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
			# 1. Take it out of the world
			held_item.get_parent().remove_child(held_item)
			# 2. Put it in the player's "hand" (the Marker2D)
			hold_position.add_child(held_item)
			# 3. Center it
			held_item.position = Vector2.ZERO
			break

func drop_item():
	if held_item:
		var item_to_drop = held_item
		hold_position.remove_child(item_to_drop)
		# Put it back into the main game scene
		get_tree().current_scene.add_child(item_to_drop)
		# Place it at the player's feet
		item_to_drop.global_position = global_position
		held_item = null

func die():
	is_dead = true

func heal(amount):
	health = clamp(health + amount, 0, max_health)
	health_bar.value = health
