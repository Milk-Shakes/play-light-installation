extends Camera2D

@export_group("Display Settings")
@export var Brightness: int = 120
@export var MaxBrightness: int = 255
@export var VerticalResolution: int = 512
@export var LEDCount: Array[int]
@export var Radius: Array[int]

@onready var NumOfRings = LEDCount.size()
@onready var ConvertedRadius: Array[int]
@onready var RingAngle: Array[float]
@onready var ScaleConversionFactor: int = VerticalResolution / Radius.max()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for b in range(NumOfRings):
		ConvertedRadius[b] = Radius[b] * ScaleConversionFactor
		RingAngle[b] = 360 / LEDCount[b]
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	for i in range(NumOfRings):
		for c in LEDCount[i]:
			#print(get_viewport().get_texture().get_image().get_pixel(700,400))
			#print(c)
			pass
	
	#print(get_viewport().get_texture().get_image().get_pixel(700,400))
	#get_viewport().get_texture().get_data().get_pixel(0.1,0.1)
	#print(get_viewport().get_texture().get_data().get_pixel(0.1,0.1))
	
	
