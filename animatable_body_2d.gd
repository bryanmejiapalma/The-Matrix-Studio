extends AnimatableBody2D

@onready var segment_1 = $Sprite2D_Part1 # The main door piece
@onready var segment_2 = $Sprite2D_Part2 # The folding piece
@onready var sound_player = $AudioStreamPlayer2D 

var is_open = false

func _input(event):
	if event.is_action_pressed("enter"):
		toggle_door()

func toggle_door():
	var tween = create_tween()
	# Run both animations at the same time for a smooth fold
	tween.set_parallel(true) 
	tween.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	if not is_open:
		# Rotate main door 90 degrees
		tween.tween_property(self, "rotation_degrees", 90, 0.6)
		# Fold the second part 90 degrees RELATIVE to the first to make the 'L'
		tween.tween_property(segment_2, "rotation_degrees", 90, 0.6)
		
		if sound_player:
			sound_player.play()
		is_open = true
	else:
		# Return both to 0
		tween.tween_property(self, "rotation_degrees", 0, 0.6)
		tween.tween_property(segment_2, "rotation_degrees", 0, 0.6)
		is_open = false
