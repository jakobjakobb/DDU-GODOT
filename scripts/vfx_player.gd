extends Node2D

const VFX_SCENE = preload("res://scenes/vfx.tscn")

func play_vfx(animation: String, position: Vector2, rotation: float = 0.0) -> void:

	var vfx = VFX_SCENE.instantiate() as AnimatedSprite2D
	
	add_child(vfx)
	
	vfx.top_level = true
	vfx.global_position = position
	vfx.global_rotation = rotation
	vfx.play(animation)

	vfx.animation_finished.connect(vfx.queue_free)
