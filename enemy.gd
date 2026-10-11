class_name Enemy
extends CharacterBody2D


@export_group("Chasing")
@export var chasing_speed: float = 50.0
@export var chasing_distance: float = 200.0

@export_group("Shooting")
@export var projectile_scene: PackedScene
@export var projectile_speed: float = 300.0
@export var shooting_distance: float = 400.0
@export var shooting_delay: float = 2.0


enum States {
	IDLING,
	CHASING,
	SHOOTING,
}

var state := States.IDLING
var player: Player
var can_shoot := true


func direction_to_player() -> Vector2:
	return (player.position - position).normalized()


func update_state() -> void:
	var distance_to_player: float = (player.position - position).length()
	
	# Uses distance to determine state
	if distance_to_player <= chasing_distance:
		start_chasing()
	elif distance_to_player <= shooting_distance and can_shoot:
		start_shooting()
	else:
		start_idling()


func _ready() -> void:
	# Easy reference to the player at all times
	player = get_tree().get_first_node_in_group("player")
	
	# Start in the default state (IDLING)
	start_idling()


func _physics_process(delta: float) -> void:
	# Controls what state is active
	if state == States.IDLING:
		idling(delta)
	elif state == States.CHASING:
		chasing(delta)
	elif state == States.SHOOTING:
		shooting(delta)
	
	# Update the state
	update_state()


#region Idling
func start_idling() -> void:
	# Set the state and any default values
	state = States.IDLING
	velocity = Vector2.ZERO


func idling(_delta: float) -> void:
	pass
#endregion

#region Chasing
func start_chasing() -> void:
	# Set the state and any default values
	state = States.CHASING


func chasing(_delta: float) -> void:
	# Functionality for the chase state
	velocity = direction_to_player() * chasing_speed
	move_and_slide()
#endregion

#region Shooting
func start_shooting() -> void:
	# Set the state and any default values
	state = States.SHOOTING
	velocity = Vector2.ZERO
	
	# Main shooting logic (creating and setting values in projectile)
	var new_node := projectile_scene.instantiate() as RigidBody2D
	get_tree().root.add_child(new_node)
	new_node.global_position = position
	new_node.linear_velocity = direction_to_player() * projectile_speed
	
	# Add delay to shooting so that there isn't rapid fire
	can_shoot = false
	await get_tree().create_timer(shooting_delay).timeout
	can_shoot = true


func shooting(_delta: float) -> void:
	pass # Nothing happens while shooting since it ends immediately
#endregion
