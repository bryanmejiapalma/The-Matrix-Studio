extends Node2D

# 1. Preload the scene - Make sure the file name is EXACTLY "Spider.tscn"
var spider_scene = preload("res://Spider.tscn")

@export var max_spiders = 10
@export var spawn_interval = 3.0 # Seconds between spawns

var current_count = 0

func _ready():
	# Configure the timer in case you forgot to do it in the editor
	if has_node("Timer"):
		$Timer.wait_time = spawn_interval
		$Timer.autostart = true
		$Timer.start()
		print("Kitchen Spawner initialized. Waiting for timer...")
	else:
		print("ERROR: KitchenSpawner needs a Timer node as a child!")

func _on_timer_timeout():
	if current_count < max_spiders:
		if spider_scene:
			var spider = spider_scene.instantiate()
			
			# Use add_child(spider) on the current scene so spiders stay in the world
			get_tree().current_scene.add_child(spider)
			
			# Set the position to the spawner's location in the kitchen
			spider.global_position = global_position
			
			current_count += 1
			print("Spider #", current_count, " spawned in the kitchen!")
		else:
			print("ERROR: spider_scene is null! Check your preload path.")
	else:
		print("Max spiders reached. Stopping spawner.")
		$Timer.stop()
