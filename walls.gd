extends StaticBody2D

@onready var sound_player = $AudioStreamPlayer2D 
var is_open = false

# Set these in the Inspector or define them here
@export var horizontal_dist: float = 64.0  # How far to slide sideways
@export var vertical_dist: float = 64.0    # How far to slide up/down
@onready var start_pos = position

func _input(event):
	if event.is_action_pressed("enter"):
		toggle_door()

func toggle_door():
	var tween = create_tween()
	# Set the transition style for the whole sequence
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	if not is_open:
		# --- OPENING (The L-Shape) ---
		# 1. Move horizontally (Right)
		tween.tween_property(self, "position:x", start_pos.x + horizontal_dist, 0.4)
		# 2. Move vertically (Up) - This starts automatically after the first one finishes
		tween.tween_property(self, "position:y", start_pos.y - vertical_dist, 0.4)
		
		if sound_player:
			sound_player.play()
		is_open = true
	else:
		# --- CLOSING (Reverse L-Shape) ---
		# 1. Move vertically back to the "elbow"
		tween.tween_property(self, "position:y", start_pos.y, 0.4)
		# 2. Move horizontally back to start
		tween.tween_property(self, "position:x", start_pos.x, 0.4)
		is_open = false
