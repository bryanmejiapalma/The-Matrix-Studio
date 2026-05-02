extends Area2D

@export var item_texture: Texture2D

func _ready():
	add_to_group("pickable")

func get_texture():
	return item_texture
