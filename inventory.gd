extends Control

@export var Slots : Array[Sprite2D]

func _ready():
	# 1. Grab all the boxes inside your HBoxContainer
	#if has_node("Slots"):
	if (Slots != null):
		for slot in Slots:
			slot.texture = null
				

# This is the function the Bat script calls
func add_item(item_texture: Texture2D):
	if item_texture == null:
		print("item texture is null, returning early...")
		return

	for slot in Slots:
		if slot.texture == null:
			print("found an empty slot")
			# Put the bat image in the first empty horizontal slot
			slot.texture = item_texture
			
			# Ensure the icon fits the square box inside the HBox
			#slot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			#slot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			
			update_inventory_visibility()
			return
	print("no empty slot found")

func update_inventory_visibility():
	var has_bat = false
	
	# Check if the "bat" is sitting in any of the horizontal slots
	for slot in Slots:
		if slot.texture != null:
			var path = slot.texture.resource_path.to_lower()
			if "bat" in path or "baseball" in path:
				has_bat = true
				if has_node("DisplayBox"):
					$DisplayBox.texture = slot.texture
				break
	
	# --- THE REVEAL ---
	# This turns your Sprite (BatImage) on or off
	if has_node("%BatImage"):
		print("fuond bat image")
		%"BatImage".visible = has_bat
	else:
		print("no bat image found")
		
	if has_node("DisplayBox"):
		$DisplayBox.visible = has_bat

# Call this if you drop the bat to hide the image again
func remove_item_by_name(item_name: String):
	for slot in Slots:
#		if slot.texture != null and item_name in slot.texture.resource_path.to_lower():
		if slot.texture != null:
			if item_name in slot.texture.resource_path.to_lower():
				slot.texture = null
				break
			else:
				print("sprite texture: " + slot.texture.resource_path.to_lower() + " does not match: " + item_name)
	update_inventory_visibility()
