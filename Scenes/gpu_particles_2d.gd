extends GPUParticles2D

@export var Player: Node
@export var Camera: Node

func _ready() -> void:
	#$Timer.start(lifetime)    # If autostart isn't selected, will start the timer
	pass


func _on_timer_timeout():
	Camera.transform = Player.transform
	emitting = true
	var root = get_tree().root
	var main_scene = root.get_child(root.get_child_count() - 1)
	get_parent().remove_child($".")
	main_scene.add_child($".")
	$".".set_owner(main_scene)
