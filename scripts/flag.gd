extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D: 
		var pos = get_meta("teleport_to")
		body.set_meta("spawnpoint", pos)
		body.position = pos
		
