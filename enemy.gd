extends CharacterBody2D

# 1. Variables and Constants
const SPEED = 120.0        
const CHASE_SPEED = 200.0  
const STOP_DISTANCE = 128.0 
const DETECTION_RANGE = 400.0
const WARNING_RANGE = 600.0 
const DAMAGE_AMOUNT = 34 

var target_player = null
var wander_direction = Vector2.RIGHT
var wander_timer = 0.0
var is_stunned: bool = false
var is_alert_active: bool = false 

@onready var alert_label = $Label 
@onready var heartbeat_audio = $AudioStreamPlayer2D 

func _ready():
	target_player = get_tree().get_first_node_in_group("player")
	
	if has_node("Killzone"):
		$Killzone.hit_player.connect(stun_enemy)
	
	if alert_label:
		alert_label.visible = false
	
	if heartbeat_audio:
		heartbeat_audio.play()

func _physics_process(delta: float) -> void:
	if is_stunned:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	check_for_player()
	handle_proximity_warning() # Runs the immediate alert logic

	if target_player and "is_dead" in target_player and not target_player.is_dead and not target_player.is_hidden:
		var target_pos = target_player.global_position
		var direction = global_position.direction_to(target_pos)
		var distance = global_position.distance_to(target_pos)
		
		look_at(target_pos)
		
		if distance > STOP_DISTANCE:
			velocity = direction * CHASE_SPEED
		else:
			velocity = Vector2.ZERO
			if target_player.has_method("take_damage"):
				if target_player.can_take_damage:
					target_player.take_damage(DAMAGE_AMOUNT)
					stun_enemy()
	else:
		patrol_behavior(delta)
		
	move_and_slide()
	
	if alert_label and alert_label.visible:
		alert_label.global_position = global_position + Vector2(-60, -80)

# --- NEW: IMMEDIATE ALERT LOGIC (NO FADING) ---
func handle_proximity_warning():
	var player = get_tree().get_first_node_in_group("player")
	if player and "is_dead" in player and not player.is_dead:
		var dist = global_position.distance_to(player.global_position)
		
		if dist < WARNING_RANGE:
			# Sudden Loud Sound
			if heartbeat_audio:
				heartbeat_audio.volume_db = 10.0 # Instant volume boost
			
			# Sudden Red Screen
			var vignette = player.get_node_or_null("CanvasLayer/BloodVignette")
			if vignette:
				vignette.modulate.a = 0.6 # Instant 60% visibility
		else:
			# Turn everything off instantly when moving away
			if heartbeat_audio: 
				heartbeat_audio.volume_db = -80.0
			var vignette = player.get_node_or_null("CanvasLayer/BloodVignette")
			if vignette: 
				vignette.modulate.a = 0.0

func stun_enemy():
	if is_stunned: return 
	is_stunned = true
	modulate = Color.YELLOW 
	if alert_label: alert_label.visible = false
	await get_tree().create_timer(2.0).timeout
	is_stunned = false
	modulate = Color.WHITE 

func check_for_player():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var dist = global_position.distance_to(player.global_position)
		if dist < DETECTION_RANGE and not player.is_hidden:
			if target_player == null and not is_alert_active:
				show_alert_popup()
			target_player = player
		else:
			target_player = null
			is_alert_active = false 

func show_alert_popup():
	if not alert_label: return
	is_alert_active = true
	alert_label.text = "! I see you!"
	alert_label.visible = true
	alert_label.scale = Vector2(0, 0)
	var tween = create_tween()
	tween.tween_property(alert_label, "scale", Vector2(1, 1), 0.1).set_trans(Tween.TRANS_BACK)
	await get_tree().create_timer(1.5).timeout
	alert_label.visible = false

func patrol_behavior(delta):
	wander_timer -= delta
	if wander_timer <= 0:
		wander_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		wander_timer = randf_range(1.5, 3.0)
	velocity = wander_direction * SPEED
	if velocity.length() > 0:
		rotation = lerp_angle(rotation, velocity.angle(), 10 * delta)
