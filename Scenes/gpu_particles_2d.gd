extends GPUParticles2D

func get_input_particles():
	pass

func _input(_event: InputEvent) -> void:
	get_input_particles() ## on input event query the get_input function (this seems to be inconsistent and laggy)
