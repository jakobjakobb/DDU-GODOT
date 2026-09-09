extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D: body.position = get_meta("teleport_to")
