class_name Player
extends CharacterBody2D


@export_group("Walking")
@export var walking_speed: float = 100.0

@export_group("Shooting")
@export var projectile_scene: PackedScene
@export var projectile_speed: float = 300.0

@export_group("Dashing")
@export var dash_speed: float = 200.0
@export var dash_time: float = 0.4


enum States {
	WALKING,
	SHOOTING,
	DASHING,
}

var state := States.WALKING

var direction := Vector2.ZERO
var facing_direction := Vector2.DOWN


func _ready() -> void:
	# Start in the default state (WALKING)
	start_walking()


func _physics_process(delta: float) -> void:
	# Controls what state is active
	if state == States.WALKING:
		walking(delta)
	elif state == States.SHOOTING:
		shooting(delta)
	elif state == States.DASHING:
		dashing(delta)


#region Walking
func start_walking() -> void:
	# Set the state and any default values
	state = States.WALKING
	velocity = Vector2.ZERO


func walking(_delta: float) -> void:
	# Walking logic
	direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * walking_speed
	
	# Useful for other states and potential animations
	if direction:
		facing_direction = direction
	
	# Check for state Changes
	if Input.is_action_just_pressed("shoot"):
		start_shooting()
		return
	
	if Input.is_action_just_pressed("dash"):
		start_dashing()
		return
	
	# Walking logic continued
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
	new_node.linear_velocity = facing_direction * projectile_speed
	
	# Change the state
	start_walking()


func shooting(_delta: float) -> void:
	pass # Nothing happens while shooting since it ends immediately
#endregion

#region Dashing
func start_dashing() -> void:
	# Set the state and any default values
	state = States.DASHING
	velocity = facing_direction * dash_speed
	
	# Set and wait for the timer that controls how long the dash is 
	await get_tree().create_timer(dash_time).timeout
	
	# Change state
	start_walking()


func dashing(_delta: float) -> void:
	# Functionality for the dash state
	move_and_slide()
#endregion
