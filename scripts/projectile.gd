extends Area2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D
@onready var collision_shape_aoe = $CollisionShape2D_AOE
@onready var speed = get_meta("speed")
@onready var duration = get_meta("duration")
@onready var impact_animation: String = get_meta("impact_animation")
@onready var damage = get_meta("damage")

var has_damaged: Array[Node2D]

func _physics_process(delta: float) -> void:
	var direction = Vector2.from_angle(rotation)
	global_position += direction * speed * delta
	
	if animated_sprite.animation != impact_animation:
		if duration == 0.0:
			queue_free()
			
		duration = max(duration - delta, 0.0)
		return
		
	if animated_sprite.frame == 2:
		collision_shape_aoe.disabled = false

func _on_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		speed = 0
		if not impact_animation.is_empty():
			animated_sprite.play(impact_animation)
	
	elif body.is_in_group("enemies"):
		if (
			body.BASIC_IMMUNE == true
			and impact_animation.is_empty()
			):
			return
		
		if body in has_damaged:
			return
			
		var damage_multiplier = 2.0 if animated_sprite.animation == impact_animation else 1.0
		body.health -= damage * damage_multiplier
		has_damaged.append(body)


func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation != impact_animation:
		return
	queue_free()
