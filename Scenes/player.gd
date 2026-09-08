extends CharacterBody2D

var pointer_rotation = 0

var player_move_direction = 0
var PlayerCrashed: bool = true

var move_direction = Vector2()

@export var speed = 100
@export var acceleration = 2

@export var Submarine: Node
@export var Collider: Node

var CurrentSpeed = int(0)

var current_speed = 0

var RequestedSpeedMode: int
var RequestedDirection: int

@onready var Pointer = $DirectionalPointer
@onready var LowSpeed = $DirectionalPointer/LowSpeed
@onready var MediumSpeed = $DirectionalPointer/MediumSpeed
@onready var HighSpeed = $DirectionalPointer/HighSpeed

var manager: GdSerialManager

func _process(_delta: float) -> void:
	manager.poll_events()

func _on_data(port: String, data: PackedByteArray):
	#print("Data from ", port, ": ", data.get_string_from_ascii(), "		")
	RequestedDirection = (((data[0]-48) * 1000)-1000) + ((data[1]-48)*100)+ ((data[2]-48)*10) + (data[3]-48)
	RequestedSpeedMode = data[4]-48
	CurrentSpeed = RequestedSpeedMode
	if (PlayerCrashed == true and CurrentSpeed == 0):
		PlayerCrashed = false
	player_move_direction = remap(RequestedDirection, 0, 4095, 0, 360)
	Pointer.rotation_degrees = player_move_direction
	#print(RequestedDirection, "		", player_move_direction)
	

func _on_disconnect(port: String):
	print("Lost connection to ", port)

func _ready() -> void:
	
	manager = GdSerialManager.new()
	manager.data_received.connect(_on_data)
	manager.port_disconnected.connect(_on_disconnect)

	# mode is optional; defaults to MODE_RAW. Use the constants for clarity:
	# MODE_RAW (emit all chunks), MODE_LINE_BUFFERED (wait for \n), MODE_CUSTOM_DELIMITER
	if manager.open_buffered("COM5", 115200, 1000, 1):
		#manager.set_delimiter("COM5",202)
		print("Connected to COM5")




#func _on_directional_pointer_direction_facing_changed(pointer_angle: Variant) -> void:
#	player_move_direction = pointer_angle
#	#print(player_move_direction)
#	## recieving the angle from the directional pointer node



func _on_cave_body_entered(_body: Node2D) -> void:
	if (move_direction.x > 5 && move_direction.y < 5 && move_direction.y > -5):
		#$"Submarine v2/SubmarineV2RedRear".visible = true
		pass
	else: if (move_direction.x < -5 && move_direction.y < 5 && move_direction.y > -5):
		#$"Submarine v2/SubmarineV2RedFront".visible = true
		pass
	else: if (move_direction.x < 5 && move_direction.x > -5 && move_direction.y > 5):
		#$"Submarine v2/SubmarineV2RedBottom".visible = true
		pass
	else: if (move_direction.x < 5 && move_direction.x > -5 && move_direction.y < -5):
		#$"Submarine v2/SubmarineV2RedTop".visible = true
		pass
		
	else: if (move_direction.x > 5 && move_direction.y > 5):
		#$"Submarine v2/SubmarineV2RedRear".visible = true
		#$"Submarine v2/SubmarineV2RedBottom".visible = true
		pass
	else: if (move_direction.x < -5 && move_direction.y < -5):
		#$"Submarine v2/SubmarineV2RedFront".visible = true
		#$"Submarine v2/SubmarineV2RedTop".visible = true
		pass
	else: if (move_direction.x < -5 && move_direction.y > 5):
		#$"Submarine v2/SubmarineV2RedBottom".visible = true
		#$"Submarine v2/SubmarineV2RedFront".visible = true
		pass
	else: if (move_direction.x > 5 && move_direction.y < -5):
		#$"Submarine v2/SubmarineV2RedTop".visible = true
		#$"Submarine v2/SubmarineV2RedRear".visible = true
		pass
	#Submarine.visible = false
	current_speed = 0
	PlayerCrashed = true
	#$DirectionalPointer/LowSpeed.visible = false
	#$DirectionalPointer/MediumSpeed.visible = false
	#$DirectionalPointer/HighSpeed.visible = false


#func _input(event):
#	if (Input.get_axis("DOWN", "UP") > 0) && !event.is_echo() && event.is_pressed():
#		if (CurrentSpeed < 3):
#			CurrentSpeed = CurrentSpeed + 1
#	else: if (Input.get_axis("DOWN", "UP") < 0) && !event.is_echo() && event.is_pressed():
#		if (CurrentSpeed > 0):
#			CurrentSpeed = CurrentSpeed - 1

	#if (CurrentSpeed == 0):
		#$DirectionalPointer/LowSpeed.visible = false
		#$DirectionalPointer/MediumSpeed.visible = false
		#$DirectionalPointer/HighSpeed.visible = false
	#else: if (CurrentSpeed == 1):
		#$DirectionalPointer/LowSpeed.visible = true
		#$DirectionalPointer/MediumSpeed.visible = false
		#$DirectionalPointer/HighSpeed.visible = false
	#else: if (CurrentSpeed == 2):
		#$DirectionalPointer/LowSpeed.visible = true
		#$DirectionalPointer/MediumSpeed.visible = true
		#$DirectionalPointer/HighSpeed.visible = false
	#else: if (CurrentSpeed == 3):
		#$DirectionalPointer/LowSpeed.visible = true
		#$DirectionalPointer/MediumSpeed.visible = true
		#$DirectionalPointer/HighSpeed.visible = true

	#current_speed = (CurrentSpeed * (speed/3))
	#print(current_speed)
	## setting the current acceleration depending on how long the up or down key is held with a slow decay

func _physics_process(_delta):
	
	#if ($CollisionShape2D.)
	if (current_speed > 9):
		#$"Submarine v2/SubmarineV2RedTop".visible = false
		#$"Submarine v2/SubmarineV2RedRear".visible = false
		#$"Submarine v2/SubmarineV2RedBottom".visible = false
		#$"Submarine v2/SubmarineV2RedFront".visible = false
		pass
	
	if (PlayerCrashed == false):
		if (current_speed < ((CurrentSpeed * (speed/3.0))-acceleration)):
			current_speed = current_speed + acceleration
		else: if (current_speed > ((CurrentSpeed * (speed/3.0))+acceleration)):
			current_speed = current_speed - acceleration
		else:
			current_speed = CurrentSpeed * (speed/3.0)
	move_direction = -(Vector2(sin(deg_to_rad(-player_move_direction)) * current_speed, cos(deg_to_rad(-player_move_direction)) * current_speed)) ## applying a vector to the velocity based on the angle recieved from direction_pointer
	velocity = move_direction
	print(PlayerCrashed)
	#get_input()
	move_and_slide()
	if (move_and_slide() == true):
		Submarine.visible = false
		current_speed = 0
		CurrentSpeed = 0
