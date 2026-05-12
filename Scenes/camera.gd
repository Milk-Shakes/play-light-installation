extends Camera2D

@export_group("Display Settings")
@export var Brightness: int = 120
@export var MaxBrightness: int = 255
@export var VerticalResolution: float = 512
@export var LEDCount: Array[int]
@export var Radius: Array[float]

var LEDMaxCount: int

@onready var NumOfRings = LEDCount.size()
@onready var ConvertedRadius: Array[float]
@onready var RingAngle: Array[float]
@onready var ScaleConversionFactor: float = ((VerticalResolution / 2) / Radius.max())
@onready var ViewportXCenter: int = (get_viewport_rect().size.x/2)
@onready var ViewportYCenter: int = (get_viewport_rect().size.y/2)

var LEDColourValue: Array[Color]
var SceneTexture


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Engine.max_fps = 15
	
	for n in range(NumOfRings):
		LEDMaxCount = LEDMaxCount + LEDCount[n]
	
	ConvertedRadius.resize(NumOfRings)
	RingAngle.resize(NumOfRings)
	LEDColourValue.resize(LEDMaxCount)
	
	for b in range(NumOfRings):
		ConvertedRadius[b] = Radius[b] * ScaleConversionFactor
		RingAngle[b] = 360.0 / LEDCount[b]
	#pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	SceneTexture = get_viewport().get_texture()
	for i in range(NumOfRings):
		for c in LEDCount[i]:
			LEDColourValue[c] = SceneTexture.get_image().get_pixel(ViewportXCenter + ConvertedRadius[i] * sin(RingAngle[i] * c),ViewportYCenter + ConvertedRadius[i] * cos(RingAngle[i] * c))
			
			#LEDColourValue[c] = (get_viewport().get_texture().get_image().get_pixel(ViewportXCenter + ConvertedRadius[i]*sin(RingAngle[i]*c),ViewportYCenter + ConvertedRadius[i]*cos(RingAngle[i]*c)))
			#print(get_viewport().get_texture().get_image().get_pixel(700,400))
			#print(c)
			#pass
	
	#print(get_viewport().get_texture().get_image().get_pixel(700,400))
	#get_viewport().get_texture().get_data().get_pixel(0.1,0.1)
	#print(get_viewport().get_texture().get_data().get_pixel(0.1,0.1))
	
	
