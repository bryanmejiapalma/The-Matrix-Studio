extends Control

var slots = []

func _ready():
	slots = $Slots.get_children()

func add_item(texture):
	for slot in slots:
		if slot.texture == null:
			slot.texture = texture
			return
