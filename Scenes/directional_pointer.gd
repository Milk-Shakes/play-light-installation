extends Sprite2D


var rotation_direction = 0

@export var test_rotation_Multiplier = 2

signal direction_facing_Changed(pointer_angle)

var pointer_rotation = 0

func get_input():
	pointer_rotation += Input.get_axis("ui_left", "ui_right") * test_rotation_Multiplier ## changing angle depending on input with a multiplier to speed up the effect
	if pointer_rotation > 360: ## clamping the angle to within 360 degrees since that's how the as5600 rotory encoder typically outputs
		pointer_rotation = 0
	elif pointer_rotation < 0:
		pointer_rotation = 360
	rotation_degrees = pointer_rotation
	direction_facing_Changed.emit(rotation_degrees) ## emitting the current angle to the Player parent Node
	#print(pointer_rotation)

func _input(event: InputEvent) -> void:
	get_input() ## on input event query the get_input function (this seems to be inconsistent and laggy)
