extends Sprite2D


var rotation_direction = 0

@export var test_rotation_Multiplier = 2

signal direction_facing_Changed(pointer_angle)

var pointer_rotation = 0

func get_input():
	pointer_rotation += Input.get_axis("ui_left", "ui_right") * test_rotation_Multiplier
	if pointer_rotation > 360:
		pointer_rotation = 0
	elif pointer_rotation < 0:
		pointer_rotation = 360
	rotation_degrees = pointer_rotation
	direction_facing_Changed.emit(rotation_degrees)
	#print(pointer_rotation)

func _input(event: InputEvent) -> void:
	get_input()
