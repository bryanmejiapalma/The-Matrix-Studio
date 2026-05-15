extends CharacterBody2D

var health = 20
var speed = 110.0
var damage = 8
var player = null
var spawn_amount = 5

# Ensure these paths match your FileSystem EXACTLY!
# If your files are "Apple.tscn" with a capital A, change these!
var apple_scene = preload("res://apple.tscn")
var banana_scene = preload("res://banana.tscn")


func _ready():
	# Explicitly add to group in code to be safe
	add_to_group("enemy")
	player = get_tree().get_first_node_in_group("player")
	print("Spider spawned and ready!")

func _physics_process(_delta):
	# Added a check to make sure player still exists
	if is_instance_valid(player) and not player.is_dead:
		# Only chase if player isn't hiding
		if player.has_method("is_hidden") and player.is_hidden:
			velocity = Vector2.ZERO
		else:
			var dir = global_position.direction_to(player.global_position)
			velocity = dir * speed
			rotation = dir.angle() 
			move_and_slide()

# Make sure your Area2D signal is connected to this function!
func _on_attack_area_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
			print("Spider bit the player for ", damage, " damage!")

# This is what your Bat script calls
func take_damage(amount):
	health -= amount
	print("Spider took ", amount, " damage! Health left: ", health)
	
	if health <= 0:
		print("Spider died!")
		spawn_loot()
		queue_free() 

func spawn_loot():
	var roll = randf() 
	var loot = null
	
	if roll < 0.15: 
		loot = apple_scene.instantiate()
		print("Dropped an apple!")
	elif roll < 0.30: 
		loot = banana_scene.instantiate()
		print("Dropped a banana!")
	else:
		print("No loot dropped this time.")
	
	if loot:
		# We add to current_scene so the loot doesn't disappear when the spider does
		get_tree().current_scene.call_deferred("add_child", loot)
		loot.global_position = global_position
