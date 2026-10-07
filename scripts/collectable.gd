extends Area2D
var has_been_collected = false
var bob_direction = 1
var bob_iterator = 0
const BOB_MULT = 0.25

func _physics_process(delta: float) -> void:
	if bob_iterator > 10:
		bob_direction *= -1
		bob_iterator = 0
		
	global_position.y += bob_direction*BOB_MULT
	bob_iterator += 1
		
	
func _on_body_entered(body: Node2D) -> void:
	if not (
		body is CharacterBody2D
		and body.is_in_group("players")
	):
		return
		
	if has_been_collected:
		return
	
	has_been_collected = true
	body.collected_collectibles += 1
	GameManager.collected_crowns += 1
	visible = false
