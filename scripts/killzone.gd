extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if not (body is CharacterBody2D):
		return
	if body.is_in_group("players"):
		body.die()
		return
	
	body.queue_free()
