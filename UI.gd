extends Control

# We create variables to hold our UI elements
var speech_label : Label

func _ready() -> void:
	# 1. Create the Label (the text that stays in game)
	speech_label = Label.new()
	speech_label.text = "" # Start empty
	speech_label.position = Vector2(100, 100) # Place it on screen
	add_child(speech_label)
	
	# 2. Create the Button
	var button := Button.new()
	button.text = "Talk"
	button.position = Vector2(100, 150) # Place it below the text
	add_child(button)
	
	# 3. Connect the button to the function
	button.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	# This changes the text inside the game window
	speech_label.text = "Hello! I am talking inside the game now."
