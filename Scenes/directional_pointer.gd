extends Sprite2D


var rotation_direction = 0

@export var Rotation_Acceleration = float(0.05)
@export var Rotation_Decceleration = float(0.5)
@export var Max_Rotation_Speed = float(3)

var Current_Rotation_Speed = float(0)

signal direction_facing_Changed(pointer_angle)

var pointer_rotation = 180

func _ready() -> void:
	rotation_degrees = pointer_rotation
	direction_facing_Changed.emit(rotation_degrees)

func _physics_process(delta: float) -> void:
	if (Input.get_axis("LEFT", "RIGHT") > 0 or Input.get_axis("LEFT", "RIGHT") < 0 && Current_Rotation_Speed <= Max_Rotation_Speed):
		Current_Rotation_Speed = Current_Rotation_Speed + (Input.get_axis("LEFT", "RIGHT") * Rotation_Acceleration)
	else: if (Current_Rotation_Speed - Rotation_Decceleration > 0):
		Current_Rotation_Speed = Current_Rotation_Speed - Rotation_Decceleration
	else: if (Current_Rotation_Speed + Rotation_Decceleration < 0):
		Current_Rotation_Speed = Current_Rotation_Speed + Rotation_Decceleration
	else:
		Current_Rotation_Speed = 0
		
	pointer_rotation += Current_Rotation_Speed ## changing angle depending on input with a multiplier to speed up the effect
	if pointer_rotation > 360: ## clamping the angle to within 360 degrees since that's how the as5600 rotory encoder typically outputs
		pointer_rotation = 0
	elif pointer_rotation < 0:
		pointer_rotation = 360
	rotation_degrees = pointer_rotation
	direction_facing_Changed.emit(rotation_degrees) ## emitting the current angle to the Player parent Node
	#print(pointer_rotation)
