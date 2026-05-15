extends StaticBody2D

@onready var sound_player = $AudioStreamPlayer2D 
var is_open = false

# Set these in the Inspector
@export var horizontal_dist: float = 64.0  # How far to slide sideways
@export var vertical_dist: float = 64.0    # How far to slide up/down

# 25 to 30 pixels means the player character must be physically touching the door
@export var interaction_radius: float = 30.0 

@onready var start_pos = position
var player_node: Node2D = null

func _ready() -> void:
	# Find the player in the group
	player_node = get_tree().get_first_node_in_group("player")

func _input(event):
	if event.is_action_pressed("enter"):
		# Always re-verify the player exists when pressing the button
		player_node = get_tree().get_first_node_in_group("player")
			
		if player_node:
			# Use global positions to eliminate offset bugs
			var distance = global_position.distance_to(player_node.global_position)
			
			# LOOK AT YOUR GODOT CONSOLE FOR THIS PRINT:
			print("DOOR LOG -> Player Distance: ", int(distance), " pixels. Required Max: ", interaction_radius)
			
			if distance <= interaction_radius:
				toggle_door()
			else:
				print("DOOR LOG -> Denied. Too far away.")
		else:
			print("DOOR LOG -> Error: No player found in the 'player' group!")

func toggle_door():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	if not is_open:
		# --- OPENING (The L-Shape) ---
		tween.tween_property(self, "position:x", start_pos.x + horizontal_dist, 0.4)
		tween.tween_property(self, "position:y", start_pos.y - vertical_dist, 0.4)
		
		if sound_player:
			sound_player.play()
		is_open = true
	else:
		# --- CLOSING (Reverse L-Shape) ---
		tween.tween_property(self, "position:y", start_pos.y, 0.4)
		tween.tween_property(self, "position:x", start_pos.x, 0.4)
		is_open = false
