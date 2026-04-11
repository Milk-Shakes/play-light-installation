extends CharacterBody2D

var pointer_rotation = 0

var player_move_direction = 0

var move_direction = Vector2()

@export var speed = 400
@export var acceleration = 4
@export var speed_decay = 1

var current_speed = 0

func _on_directional_pointer_direction_facing_changed(pointer_angle: Variant) -> void:
	player_move_direction = pointer_angle
	#print(player_move_direction)
	## recieving the angle from the directional pointer node


func get_input():
	if current_speed <= speed && current_speed >= -speed:
		current_speed += Input.get_axis("ui_up", "ui_down") * acceleration
	if current_speed < 0:
		current_speed += speed_decay
	elif current_speed > 0:
		current_speed += -speed_decay
	#print(current_speed)
	## setting the current acceleration depending on how long the up or down key is held with a slow decay

func _physics_process(delta):
	move_direction = Vector2(sin(deg_to_rad(-player_move_direction)) * current_speed, cos(deg_to_rad(-player_move_direction)) * current_speed) ## applying a vector to the velocity based on the angle recieved from direction_pointer
	velocity = move_direction
	get_input()
	move_and_slide()
