extends Area2D


var is_held = false
var player_in_range = null 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	collision_mask = 1 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		if not is_held and player_in_range != null:
			pick_up(player_in_range)
		elif is_held:
			drop_Key()
			
func pick_up(player_node: Node2D) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
