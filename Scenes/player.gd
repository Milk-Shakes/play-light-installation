extends CharacterBody2D

var pointer_rotation = 0

var player_move_direction = 0

var move_direction = Vector2()

@export var speed = 400
@export var acceleration = 4

var current_speed = 0

func _on_directional_pointer_direction_facing_changed(pointer_angle: Variant) -> void:
	player_move_direction = pointer_angle
	print(player_move_direction)


func get_input():
	if current_speed <= speed && current_speed >= -speed:
		current_speed += Input.get_axis("ui_up", "ui_down") * acceleration
	if current_speed < 0:
		current_speed += 1
	elif current_speed > 0:
		current_speed += -1
	#print(current_speed)

func _physics_process(delta):
	move_direction = Vector2(cos(deg_to_rad(player_move_direction)) * current_speed, sin(deg_to_rad(player_move_direction)) * current_speed)
	velocity = move_direction
	get_input()
	move_and_slide()
