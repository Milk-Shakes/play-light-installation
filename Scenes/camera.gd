extends Camera2D

@export_group("Display Settings")
@export var Brightness: int = 120
@export var MaxBrightness: int = 255
@export var LEDCount: Array[int] = [ 63, 94, 126, 157, 189, 220, 251, 283, 314, 346, 377, 409, 440, 471 ]
@export var Radius: Array[float] = [ 102.0, 152.0, 202.0, 252.0, 302.0, 352.0, 402.0, 452.0, 502.0, 552.0, 602.0, 652.0, 702.0, 752.0 ]

@export var FPSCap: int = 15

var LEDMaxCount: int

@onready var NumOfRings = LEDCount.size()
@onready var ConvertedRadius: Array[float]
@onready var RingAngle: Array[float]

@onready var ViewportHeight: float = get_viewport_rect().size.y
@onready var ViewportXCenter: int = (get_viewport_rect().size.x/2)
@onready var ViewportYCenter: int = (ViewportHeight/2)

@onready var ScaleConversionFactor: float = (((ViewportHeight / 2)-10) / Radius.max())

var LEDColourValue: Array[Vector3i]
var CurrentColourValue: Color
var SceneTexture

var thread: Thread


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Engine.max_fps = FPSCap
	
	thread = Thread.new()
	
	thread.start(_DisplayColorScan.bind("Display1"))
	
	for n in range(NumOfRings):
		LEDMaxCount = LEDMaxCount + LEDCount[n]
	
	ConvertedRadius.resize(NumOfRings)
	RingAngle.resize(NumOfRings)
	LEDColourValue.resize(LEDMaxCount)
	
	for b in range(NumOfRings):
		ConvertedRadius[b] = Radius[b] * ScaleConversionFactor
		RingAngle[b] = 360.0 / LEDCount[b]
	#pass # Replace with function body.


func _DisplayColorScan(Scan):
	pass
	
	#for i in range(NumOfRings):
	#	for c in LEDCount[i]:
	#		CurrentColourValue = Scan.get_pixel(ViewportXCenter +  ConvertedRadius[i] * sin(RingAngle[i] * c),ViewportYCenter + ConvertedRadius[i] * cos(RingAngle[i] * c))
	#		LEDColourValue[c][0] = CurrentColourValue.r8
	#		LEDColourValue[c][1] = CurrentColourValue.g8
	#		LEDColourValue[c][2] = CurrentColourValue.b8

func save_to_file():
	var file = FileAccess.open("res://save_game.dat", FileAccess.WRITE)
	SceneTexture.save_png("Test.png")    
	for k in LEDMaxCount:
		file.store_string(" {" + str(LEDColourValue[k][0]) + "," + str(LEDColourValue[k][1]) + "," + str(LEDColourValue[k][2]) + "} , ")

	file.close() 

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_SPACE:
			save_to_file()

#func _draw():
#	for i in range(NumOfRings):
#		for c in LEDCount[i]:
#			var CurrentAngle = deg_to_rad(RingAngle[i] * c)
#			var TestX = int(ConvertedRadius[i] * sin(CurrentAngle))
#			var testY = int(ConvertedRadius[i] * cos(CurrentAngle))
#			#print(RingAngle[i])
#			#print(str(RingAngle[i]) + "  |  " + str(c) + "  |  " + str(CurrentAngle) + "  |  " + str(ConvertedRadius[i]) + "  |  " + str(ConvertedRadius[i] * sin(CurrentAngle)))
#			draw_circle(Vector2(TestX,testY), 2, Color8(255,0,0,255), true)
#   			#draw_circle(Vector2(0,0), 5, Color8(255,0,0,255), true)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	SceneTexture = get_viewport().get_texture().get_image()
	var currentled = 0
	for i in range(NumOfRings):
		for c in LEDCount[i]:
			var CurrentAngle = float(deg_to_rad(RingAngle[i] * c)) 
			var TestX = int(ViewportXCenter + (ConvertedRadius[i] * sin(CurrentAngle)))
			var testY = int(ViewportYCenter + (ConvertedRadius[i] * cos(CurrentAngle)))
			CurrentColourValue = SceneTexture.get_pixel(TestX,testY)
			#print(str(ViewportXCenter) + "  |  " + str(ViewportYCenter))
			#print(str(TestX) + "  |  " + str(testY) + "  |  " + str(currentled) + "  |  " + str(CurrentAngle))
			LEDColourValue[currentled][0] = CurrentColourValue.r8
			LEDColourValue[currentled][1] = CurrentColourValue.g8
			LEDColourValue[currentled][2] = CurrentColourValue.b8
			currentled = currentled + 1
		#print("NEXT RING")
	currentled = 0 
	#_DisplayColorScan(SceneTexture)
##	queue_redraw()
			#LEDColourValue[c] = (get_viewport().get_texture().get_image().get_pixel(ViewportXCenter + ConvertedRadius[i]*sin(RingAngle[i]*c),ViewportYCenter + ConvertedRadius[i]*cos(RingAngle[i]*c)))
			#print(get_viewport().get_texture().get_image().get_pixel(700,400))
			#print(c)
			#pass
	
	#print(get_viewport().get_texture().get_image().get_pixel(700,400))
	#get_viewport().get_texture().get_data().get_pixel(0.1,0.1)
	#print(get_viewport().get_texture().get_data().get_pixel(0.1,0.1))
	
func _exit_tree():
	thread.wait_to_finish()
