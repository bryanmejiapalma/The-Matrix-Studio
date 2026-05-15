extends Control

# This variable links the script to your label in the scene
@onready var talk_label: RichTextLabel = %enemy_speak

# The hashtag name
var enemy_id: String = "#Principal" 

# The list of lines she will say
var dialogue_lines: Array = [
	"Come with me.",
	"Come to the principle office.",
	"We have things to discuss regarding your conduct.",
	"Don't make me ask twice."
]

var current_index: int = 0
var next_button: Button

func _ready() -> void:
	# 1. Force the label to show the first line immediately
	show_line()
	
	# 2. Create the button dynamically
	next_button = Button.new()
	next_button.text = "Next Line"
	add_child(next_button)
	
	# 3. Move button to bottom right
	next_button.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT, Control.PRESET_MODE_MINSIZE, 50)
	
	# 4. Connect the button to the 'next' function
	next_button.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	# Move to the next line
	current_index += 1
	
	if current_index < dialogue_lines.size():
		show_line()
	else:
		talk_label.text = "[b]" + enemy_id + ":[/b] ...Dismissed."
		next_button.disabled = true
		next_button.text = "End"

func show_line() -> void:
	# This function handles the actual talking
	if talk_label:
		talk_label.bbcode_enabled = true
		var current_text = dialogue_lines[current_index]
		talk_label.text = "[b]" + enemy_id + ":[/b] " + current_text
	else:
		print("Error: enemy_speak label not found! Check your Unique Name.")
