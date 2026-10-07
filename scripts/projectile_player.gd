extends Node2D

const PROJECTILE_SCENE = preload("res://scenes/projectile.tscn")

func play_projectile(
	animation: String, 
	damage: float,
	position: Vector2, 
	rotation: float = 0.0, 
	speed: float = 1.0, 
	duration: float = 1.0, 
	impact_animation: String = ""
	) -> void:

	var projectile = PROJECTILE_SCENE.instantiate() as Area2D
	var animated_sprite = projectile.get_node("AnimatedSprite2D") as AnimatedSprite2D
	
	projectile.top_level = true
	projectile.global_position = position
	projectile.global_rotation = rotation
	projectile.set_meta("speed", speed)
	projectile.set_meta("duration", duration)
	projectile.set_meta("impact_animation", impact_animation)
	projectile.set_meta("damage", damage)

	
	add_child(projectile)
	animated_sprite.play(animation)
