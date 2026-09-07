extends CharacterBody2D


const SPEED = 130.0
const JUMP_VELOCITY = -400.0
const WALL_SLOWDOWN = 0.8

var stick_to_wall = true

func _physics_process(delta: float) -> void:

	if not (is_on_floor() or (is_on_wall() and stick_to_wall)):
		velocity += get_gravity() * delta
		if not is_on_wall(): stick_to_wall = true

	if is_on_wall() and stick_to_wall:
		velocity *= WALL_SLOWDOWN
	# Handle jump.
	
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			stick_to_wall = true
			
		if is_on_wall() and stick_to_wall:
			velocity.y = JUMP_VELOCITY
			stick_to_wall = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	position = Vector2(512, -80)
