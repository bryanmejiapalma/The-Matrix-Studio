extends Control

# This matches the name of the Panel you made for keybinds
@onready var controls_panel = $ControlsPanel

func _ready():
	# 1. FIX LAYOUT: Force the menu to fill the screen instantly
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# 2. FIX MOUSE: Ensure the menu can actually be clicked
	mouse_filter = Control.MOUSE_FILTER_STOP
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# 3. FIX VISIBILITY: Make sure the menu is seen but panel is hidden
	self.visible = true
	if controls_panel:
		controls_panel.visible = false
	
	print("Main Menu Ready")

# --- BUTTON SIGNALS ---
# IMPORTANT: You must re-connect these in the 'Node' tab if you renamed buttons!

func _on_start_button_pressed():
	# Based on your screenshot, check if it's "game.tscn" or "Game.tscn"
	# Godot is case-sensitive!
	var game_scene_path = "res://game.tscn"
	
	if ResourceLoader.exists(game_scene_path):
		get_tree().change_scene_to_file(game_scene_path)
	else:
		print("CRITICAL ERROR: Cannot find scene at: ", game_scene_path)

func _on_controls_button_pressed():
	if controls_panel:
		controls_panel.visible = true

func _on_close_controls_pressed():
	if controls_panel:
		controls_panel.visible = false

func _on_quit_button_pressed():
	get_tree().quit()
