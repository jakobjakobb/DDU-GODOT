extends Area2D



func _on_body_entered(body: Node2D) -> void:
	if not (
		body is CharacterBody2D
		and body.is_in_group("players")
	):
		return
	body.UNLOCKED_TERTIARY = true
	$AnimatedSprite2D.play("no_staff")
	$Panel.visible = false
	$Panel2.visible = true
