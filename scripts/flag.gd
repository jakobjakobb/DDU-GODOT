extends Area2D
@export var checkpoint = false

func _on_body_entered(body: Node2D) -> void:
	if not (
		body is CharacterBody2D
		and body.is_in_group("players")
	):
		return
	
	var pos = global_position if checkpoint else get_meta("teleport_to")
	body.set_meta("spawnpoint", pos)
	if not checkpoint:
		body.global_position = pos
		
