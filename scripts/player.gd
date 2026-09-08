extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

const SPEED = 130.0
const JUMP_VELOCITY = -400.0
const LAUNCH_VELOCITY = 750.0
const WALL_SLOWDOWN = 0.8

var stick_to_wall = true

func _physics_process(delta: float) -> void:

	if not (is_on_floor() or (is_on_wall() and stick_to_wall)):
		velocity += get_gravity() * delta 
		if not is_on_wall(): stick_to_wall = true

	if is_on_wall() and stick_to_wall:
		velocity *= WALL_SLOWDOWN
	
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			stick_to_wall = true
			
		if is_on_wall() and stick_to_wall:
			var launch_direction = _get_wall_direction() * -1
			velocity.x += LAUNCH_VELOCITY * launch_direction
			velocity.y = JUMP_VELOCITY
			stick_to_wall = false

	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		

	move_and_slide()
	_state_process()

func _state_process() -> void:
	var state
	var wall_direction = _get_wall_direction()
	var input_direction = Input.get_axis("left", "right")
	var direction = wall_direction if wall_direction else input_direction
	if Input.is_action_just_pressed("jump"):
		state = "jumping"
	elif is_on_wall():
		state = "climbing"
	elif not is_on_floor():
		state = "falling"
	elif direction: 
		state = "walking"
	else:
		state = "idling"
	_sprite_change(state, direction)

	
func _sprite_change(state, direction) -> void:
	if direction: animated_sprite.flip_h = true if direction < 0 else false
	match state:
		"idling": animated_sprite.animation = "idle"
		"climbing": animated_sprite.animation = "climb"
		"falling": animated_sprite.animation = "jump"
		"jumping": animated_sprite.animation = "jump"
		"walking": animated_sprite.animation = "walk"

func _get_wall_direction() -> int:
	if not is_on_wall(): return 0
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision.get_normal().x > 0:
			return -1
		elif collision.get_normal().x < 0:
			return 1
	return 0

func _on_area_2d_body_entered(body: Node2D) -> void:
	position = Vector2(512, -80)
