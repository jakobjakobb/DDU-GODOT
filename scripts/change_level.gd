extends Area2D
@export var TELEPORT_TO: Vector2


func _on_body_entered(body: Node2D) -> void:
	if not (
		body is CharacterBody2D
		and body.is_in_group("players")
	):
		return
		
	body.global_position = TELEPORT_TO
	GameManager.change_level()
		
	
