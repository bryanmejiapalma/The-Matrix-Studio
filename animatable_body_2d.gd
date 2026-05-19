extends AnimatableBody2D

# SAFE: Using get_node_or_null to prevent immediate crashes if parts are missing
@onready var segment_1 = get_node_or_null("Sprite2D_Part1")
@onready var segment_2 = get_node_or_null("Sprite2D_Part2")
@onready var sound_player = get_node_or_null("AudioStreamPlayer2D")

var is_open = false
var target_angle = 0.0

# This locks the hinge position so the door never "slides" forward
@onready var hinge_global_pos = global_position 

func _input(event):
	# Make sure you have an action named "enter" in Input Map
	if event.is_action_pressed("enter"):
		toggle_door()

func toggle_door():
	# Keep the corner stuck at the original coordinate
	global_position = hinge_global_pos
	
	var tween = create_tween()
	tween.set_parallel(true) 
	tween.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	# GHOST MODE: Temporarily disable collision
	# This is the fix to stop the door from hitting or shoving the player
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	
	if not is_open:
		# SWING AWAY LOGIC:
		var player = get_tree().get_first_node_in_group("player")
		target_angle = 90.0 # Default
		
		if player:
			# Use Dot Product to see if player is in front or behind
			var to_player = (player.global_position - global_position).normalized()
			var door_forward = Vector2.UP.rotated(global_rotation)
			
			# If player is in the path, swing the other way (-90)
			if door_forward.dot(to_player) > 0:
				target_angle = -90.0
		
		# Animate the main rotation (The hinge)
		tween.tween_property(self, "rotation_degrees", target_angle, 0.6)
		
		# SAFE CHECK: Only animate segment_2 if it actually exists in the scene
		if segment_2 and is_instance_valid(segment_2):
			var fold_dir = 90 if target_angle > 0 else -90
			tween.tween_property(segment_2, "rotation_degrees", fold_dir, 0.6)
		
		if sound_player and is_instance_valid(sound_player):
			sound_player.play()
		is_open = true
	else:
		# CLOSE ANIMATION: Back to 0
		tween.tween_property(self, "rotation_degrees", 0, 0.6)
		
		# SAFE CHECK: Only animate segment_2 if it actually exists in the scene
		if segment_2 and is_instance_valid(segment_2):
			tween.tween_property(segment_2, "rotation_degrees", 0, 0.6)
		is_open = false

	# SOLID MODE: Re-enable collision only when the animation is finished
	tween.chain().tween_callback(func(): 
		set_collision_layer_value(1, true)
		set_collision_mask_value(1, true)
	)
