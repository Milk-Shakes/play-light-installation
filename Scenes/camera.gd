extends Camera2D


@export_group("Display Settings")
@export var Brightness: int = 120
@export var MaxBrightness: int = 255
@export var LEDCount: Array[int] = [ 63, 94, 126, 157, 189, 220, 251, 283, 314, 346, 377, 409, 440, 471 ]
@export var Radius: Array[float] = [ 102.0, 152.0, 202.0, 252.0, 302.0, 352.0, 402.0, 452.0, 502.0, 552.0, 602.0, 652.0, 702.0, 752.0 ]

@export var FPSCap: int = 15

@export var Port = "COM7"
@export var BaudRate = 115200


#var server = UDPServer.new()
#var peers = []
#var CurrentPacket = int()

var RecievedMessage

var LEDMaxCount: int

@onready var NumOfRings = LEDCount.size()
@onready var ConvertedRadius: Array[float]
@onready var RingAngle: Array[float]

@onready var ViewportHeight: float = get_viewport_rect().size.y
@onready var ViewportXCenter = int(get_viewport_rect().size.x/2)
@onready var ViewportYCenter = int(ViewportHeight/2)

@onready var ScaleConversionFactor: float = (((ViewportHeight / 2)-10) / Radius.max())

#var LEDColourValue: Array[int]
#var LEDColourValue: Array[Vector3i]
var colourtestarray: PackedByteArray
var OLDColourTestArray: PackedByteArray
#var colourtest = Color8(62, 51, 126, 255)

var OLDTestFailed: bool = false

var DisplayCommand: PackedByteArray

#var LEDColourValueR: Array[int]
#var LEDColourValueG: Array[int]
#var LEDColourValueB: Array[int]
var CurrentColourValue: Color
var SceneTexture: Image

var thread1: Thread
var thread2: Thread

var PrintDisplay = false

var hid = Hid.new()
var Connected = false



# Called when the node enters the scene tree for the first time.
func _ready() -> void:

# List all connected HID devices.
	#var devices = Hid.list_devices()
	#print(devices)

	
	# Open by vender id and product id
	hid.open(5824, 1158)
	if hid.open(5824, 1158) == true:
		Connected = true
		print("Teensy found! Pushing display data")
	else:
		print("Teensy not found. disabled HID write")
	# Or open by device path
	#hid.open_path(path)
	# Or open by serial number
	#hid.open_serial(vid, pid, serial_number)

	# Then you can read HID report data from device.
	#var report_recv = hid.read(64)
	#var report_recv = hid.read_timeout(64, 10)
	# And write report data to HID
	
	
	colourtestarray.resize(64)
	DisplayCommand.resize(64)
	for i in 64:
		DisplayCommand.encode_s8(i, 255)
	DisplayCommand.encode_s8(3, 123)
	DisplayCommand.encode_s8(4, 45)
	DisplayCommand.encode_s8(5, 67)
	DisplayCommand.encode_s8(6, 89)
	DisplayCommand.encode_s8(7, 10)
	DisplayCommand.encode_s8(8, 11)
	
	
	Engine.max_fps = FPSCap
	
	
	
	for n in range(NumOfRings):
		LEDMaxCount = LEDMaxCount + LEDCount[n]
		
	OLDColourTestArray.resize(LEDMaxCount+100)
	for i in LEDMaxCount:
		OLDColourTestArray.encode_s8(i, 254)
	
	ConvertedRadius.resize(NumOfRings)
	RingAngle.resize(NumOfRings)
	#LEDColourValueR.resize(LEDMaxCount)
	#LEDColourValueG.resize(LEDMaxCount)
	#LEDColourValueB.resize(LEDMaxCount)
	#LEDColourValue.resize(LEDMaxCount)
	
	for b in range(NumOfRings):
		ConvertedRadius[b] = Radius[b] * ScaleConversionFactor
		RingAngle[b] = 360.0 / LEDCount[b]
	#pass # Replace with function body.
	thread1 = Thread.new()
	thread2 = Thread.new()
	
	thread1.start(_DisplayColorScan)
	thread2.start(PushHID.bind(colourtestarray))


#func _on_data(port: String, data: PackedByteArray):
	#print("Data from ", port, ": ", data.get_string_from_ascii())
#	pass

#func _on_disconnect(port: String):
#	print("Lost connection to ", port)

func PushHID(DataToSend:PackedByteArray):
	if Connected == true:
		hid.write(DataToSend)
	else:
		pass

func _DisplayColorScan():
	if (PrintDisplay == true):
		SceneTexture = get_viewport().get_texture().get_image()
		var currentled = 0
		var currentled2 = 0
		var BytesToSend = 4
		for i in range(NumOfRings):
			for c in LEDCount[i]:
				var CurrentAngle = float(deg_to_rad(RingAngle[i] * c)) 
				var TestX = int(ViewportXCenter + (ConvertedRadius[i] * sin(CurrentAngle)))
				var testY = int(ViewportYCenter + (ConvertedRadius[i] * cos(CurrentAngle)))
				CurrentColourValue = SceneTexture.get_pixel(TestX,testY)
				
				if (BytesToSend < 5):
					colourtestarray.encode_u8(0, currentled)
					colourtestarray.encode_u8(1, currentled2)
				colourtestarray.encode_u8(BytesToSend, CurrentColourValue.r8)
				colourtestarray.encode_u8(BytesToSend+1, CurrentColourValue.g8)
				colourtestarray.encode_u8(BytesToSend+2, CurrentColourValue.b8)
				
				if OLDColourTestArray.decode_s8(currentled+(currentled2*255)+(BytesToSend-4)) != CurrentColourValue.r8:
					OLDTestFailed = true
					OLDColourTestArray.encode_s8(currentled+(currentled2*255)+(BytesToSend-4), CurrentColourValue.r8)
				if OLDColourTestArray.decode_s8(currentled+(currentled2*255)+(BytesToSend-3)) != CurrentColourValue.g8:
					OLDTestFailed = true
					OLDColourTestArray.encode_s8(currentled+(currentled2*255)+(BytesToSend-3), CurrentColourValue.g8)
				if OLDColourTestArray.decode_s8(currentled+(currentled2*255)+(BytesToSend-2)) != CurrentColourValue.b8:
					OLDTestFailed = true
					OLDColourTestArray.encode_s8(currentled+(currentled2*255)+(BytesToSend-2), CurrentColourValue.b8)
				
				BytesToSend = BytesToSend + 3
				if (BytesToSend > 63):
					#print(var_to_bytes(colourtestarray))
					if OLDTestFailed == true:
						PushHID(var_to_bytes(colourtestarray).slice(7, 72))
					else:
						OLDTestFailed = false
					#hid.write(var_to_bytes(colourtestarray).slice(7, 72))
					BytesToSend = 4
				
				#LEDColourValueR[currentled] = CurrentColourValue.r8
				#LEDColourValueG[currentled] = CurrentColourValue.g8
				#LEDColourValueB[currentled] = CurrentColourValue.b8
				if (currentled < 256):
					currentled = currentled + 1
				else:
					currentled = 0
					currentled2 = currentled2 + 1

		currentled = 0 
		currentled2 = 0 
		if (BytesToSend != 0):
			if OLDTestFailed == true:
				PushHID(var_to_bytes(colourtestarray).slice(7, 72))
			else:
				OLDTestFailed = false
			#hid.write(var_to_bytes(colourtestarray).slice(7, 72))
			BytesToSend = 4
			
		PushHID(var_to_bytes(DisplayCommand))
		OLDTestFailed = false
	PrintDisplay = false
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	#SceneTexture = get_viewport().get_texture().get_image()
	PrintDisplay = true
	_DisplayColorScan()
func _exit_tree():
	thread1.wait_to_finish()
	thread2.wait_to_finish()
