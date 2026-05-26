extends Camera2D


@export_group("Display Settings")
@export var Brightness: int = 120
@export var MaxBrightness: int = 255
@export var LEDCount: Array[int] = [ 63, 94, 126, 157, 189, 220, 251, 283, 314, 346, 377, 409, 440, 471 ]
@export var Radius: Array[float] = [ 102.0, 152.0, 202.0, 252.0, 302.0, 352.0, 402.0, 452.0, 502.0, 552.0, 602.0, 652.0, 702.0, 752.0 ]

@export var FPSCap: int = 15

@export var Port = "COM7"
@export var BaudRate = 115200


var server = UDPServer.new()
var peers = []
var CurrentPacket = int()

var manager: GdSerialManager

var LEDMaxCount: int

@onready var NumOfRings = LEDCount.size()
@onready var ConvertedRadius: Array[float]
@onready var RingAngle: Array[float]

@onready var ViewportHeight: float = get_viewport_rect().size.y
@onready var ViewportXCenter: int = (get_viewport_rect().size.x/2)
@onready var ViewportYCenter: int = (ViewportHeight/2)

@onready var ScaleConversionFactor: float = (((ViewportHeight / 2)-10) / Radius.max())

#var LEDColourValue: Array[int]
#var LEDColourValue: Array[Vector3i]
var LEDColourValueR: Array[int]
var LEDColourValueG: Array[int]
var LEDColourValueB: Array[int]
var CurrentColourValue: Color
var SceneTexture

var thread: Thread



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#manager = GdSerialManager.new()
	#manager.data_received.connect(_on_data)
	#manager.port_disconnected.connect(_on_disconnect)
	
	server.listen(1234)
	
	

	
	#if manager.open(Port, BaudRate, 1000):
	#	print("Connected to " + str(Port))
	
	#manager.MODE_RAW	
	#manager.MODE_CUSTOM_DELIMITER
	#manager.set_delimiter(Port, 255)
	
	Engine.max_fps = FPSCap
	
	thread = Thread.new()
	
	thread.start(_DisplayColorScan.bind("Display1"))
	
	for n in range(NumOfRings):
		LEDMaxCount = LEDMaxCount + LEDCount[n]
	
	ConvertedRadius.resize(NumOfRings)
	RingAngle.resize(NumOfRings)
	LEDColourValueR.resize(LEDMaxCount)
	LEDColourValueG.resize(LEDMaxCount)
	LEDColourValueB.resize(LEDMaxCount)
	#LEDColourValue.resize(LEDMaxCount)
	
	for b in range(NumOfRings):
		ConvertedRadius[b] = Radius[b] * ScaleConversionFactor
		RingAngle[b] = 360.0 / LEDCount[b]
	#pass # Replace with function body.


#func _on_data(port: String, data: PackedByteArray):
	#print("Data from ", port, ": ", data.get_string_from_ascii())
#	pass

#unc _on_disconnect(port: String):
#	print("Lost connection to ", port)

func _DisplayColorScan(scan):
	#pass
	server.poll() # Important!
	if server.is_connection_available():
		var peer = server.take_connection()
		var packet = peer.get_packet()
		print("Accepted peer: %s:%s" % [peer.get_packet_ip(), peer.get_packet_port()])
		print("Received data: %s" % [packet.get_string_from_utf8()])
		# Reply so it knows we received the message.
		peer.put_packet(packet)
		# Keep a reference so we can keep contacting the remote peer.
		peers.append(peer)
	
	for peer in peers:
		peer.put_packet("Packet ".to_ascii_buffer() + str(CurrentPacket).to_ascii_buffer() + " Red ".to_ascii_buffer() + str(LEDColourValueR).to_ascii_buffer() + " end".to_ascii_buffer())
		peer.put_packet("Packet ".to_ascii_buffer() + str(CurrentPacket).to_ascii_buffer() + " Green ".to_ascii_buffer() + str(LEDColourValueG).to_ascii_buffer() + " end".to_ascii_buffer())
		peer.put_packet("Packet ".to_ascii_buffer() + str(CurrentPacket).to_ascii_buffer() + " Blue ".to_ascii_buffer() + str(LEDColourValueB).to_ascii_buffer() + " end".to_ascii_buffer())
	
	if (CurrentPacket < 255):
		CurrentPacket = CurrentPacket + 1
	else:
		CurrentPacket = 0
	
	#for i in range(NumOfRings):
	#	for c in LEDCount[i]:
	#		CurrentColourValue = Scan.get_pixel(ViewportXCenter +  ConvertedRadius[i] * sin(RingAngle[i] * c),ViewportYCenter + ConvertedRadius[i] * cos(RingAngle[i] * c))
	#		LEDColourValue[c][0] = CurrentColourValue.r8
	#		LEDColourValue[c][1] = CurrentColourValue.g8
	#		LEDColourValue[c][2] = CurrentColourValue.b8

func save_to_file():
	var file = FileAccess.open("res://save_game.dat", FileAccess.WRITE)
	SceneTexture.save_png("Test.png")    
	#for k in LEDMaxCount:
		#file.store_string(" {" + str(LEDColourValue[k][0]) + "," + str(LEDColourValue[k][1]) + "," + str(LEDColourValue[k][2]) + "} , ")

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
	#manager.poll_events()
	
	

		#pass # Do something with the connected peers.
	
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
			
			#LEDColourValue[currentled][0] = CurrentColourValue.r8
			#LEDColourValue[currentled][1] = CurrentColourValue.g8
			#LEDColourValue[currentled][2] = CurrentColourValue.b8
			
			LEDColourValueR[currentled] = CurrentColourValue.r8
			LEDColourValueG[currentled] = CurrentColourValue.g8
			LEDColourValueB[currentled] = CurrentColourValue.b8
			currentled = currentled + 1
			
			#manager.to_string()
			#manager.write(Port, var_to_bytes(currentled))
			#manager.write(Port, var_to_bytes(clamp(CurrentColourValue.r8, 1, 254)))
			#manager.write(Port, var_to_bytes(clamp(CurrentColourValue.g8, 1, 254)))
			#manager.write(Port, var_to_bytes(clamp(CurrentColourValue.b8, 1, 254)))
			#manager.write(Port, var_to_bytes(255))
			#manager.to_string()
			#currentled = currentled + 1
		
		#print("NEXT RING")
	currentled = 0 
	
	_DisplayColorScan(1)
	
	#var redvalue = str(LEDColourValueR).to_utf8_buffer().hex_encode()
	

	
	#for peer in peers:
	#	peer.put_packet("Packet ".to_ascii_buffer() + str(CurrentPacket).to_ascii_buffer() + " Red ".to_ascii_buffer() + str(LEDColourValueR).to_ascii_buffer() + " end".to_ascii_buffer())
	#	peer.put_packet("Packet ".to_ascii_buffer() + str(CurrentPacket).to_ascii_buffer() + " Green ".to_ascii_buffer() + str(LEDColourValueG).to_ascii_buffer() + " end".to_ascii_buffer())
	#	peer.put_packet("Packet ".to_ascii_buffer() + str(CurrentPacket).to_ascii_buffer() + " Blue ".to_ascii_buffer() + str(LEDColourValueB).to_ascii_buffer() + " end".to_ascii_buffer())
	
	#if (CurrentPacket < 255):
	#	CurrentPacket = CurrentPacket + 1
	#else:
	#	CurrentPacket = 0
	#for i in range(0, peers.size()):
		#var byte_array = LEDColourValueR
		
		#var chunk_size = 8192 
		#var chunk_size = 240
		#for j in range(0, byte_array.size(), chunk_size):
		#	var chunk = byte_array.slice(j, j + chunk_size)
		#	for peer in peers:
		#		peer.put_packet(chunk)
	#for d in LEDMaxCount:
	#print(var_to_bytes(LEDColourValue))
	#manager.write(Port, var_to_bytes(LEDColourValue))
	#manager.write(Port, var_to_bytes(255))
	#var_to_bytes(LEDColourValue)
	#manager.close(Port)
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
