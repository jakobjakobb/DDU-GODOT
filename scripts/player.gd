extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

const SPEED = 130.0
const JUMP_VELOCITY = -400.0
const LAUNCH_VELOCITY = 750.0
const WALL_SLOWDOWN = 0.8

const ANIMATION_STATES = {
	"idling": "idle",
	"climbing": "climb",
	"falling": "jump",
	"jumping": "jump",
	"walking": "walk"
}

var stick_to_wall = true
var current_state = "idling"
var current_action = null
var current_direction = 0


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
			velocity = Vector2(LAUNCH_VELOCITY * launch_direction, JUMP_VELOCITY)
			stick_to_wall = false
	
	if Input.is_action_just_pressed("down"):
		if is_on_wall() and stick_to_wall:
			stick_to_wall = false

	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		

	move_and_slide()
	_state_process()
	_action_process()
	_sprite_change()

func _state_process() -> void:
	var wall_direction = _get_wall_direction()
	var input_direction = Input.get_axis("left", "right")
	current_direction = wall_direction if wall_direction else input_direction
	if Input.is_action_just_pressed("jump"):
		current_state = "jumping"
	elif is_on_wall() and stick_to_wall:
		current_state = "climbing"
	elif not is_on_floor():
		current_state = "falling"
	elif current_direction: 
		current_state = "walking"
	else:
		current_state = "idling"

func _sprite_change() -> void:
	if current_direction: animated_sprite.flip_h = true if current_direction < 0 else false
	if current_action:
		var animation_finished = animated_sprite.animation_finished
		if animation_finished not in [true, false]: animation_finished = false
		print(animated_sprite.animation," ", current_action, " ", animation_finished)
		if animation_finished: current_action = null; print(1)
		elif animated_sprite.animation in ANIMATION_STATES.keys(): match current_action:
			"primary_attack": animated_sprite.animation = ["attack_slash_down", "attack_slash_up"].pick_random()
			"secondary_attack": animated_sprite.animation = "attack_cast"
			"falling_attack":
				animated_sprite.animation = "attack_fall_fall" if current_state == "falling" else "attack_fall_land"
			
	else: animated_sprite.animation = ANIMATION_STATES[current_state]

func _action_process() -> void:
	if current_action: return
	if Input.is_action_just_pressed("primary"):
		current_action = "primary_attack"
	elif Input.is_action_just_pressed("secondary"):
		current_action = "secondary_attack"
	elif Input.is_action_pressed("down") and current_state == "falling":
		current_action = "falling_attack"
		
func _get_wall_direction() -> int:
	if not is_on_wall(): return 0
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision.get_normal().x > 0:
			return -1
		elif collision.get_normal().x < 0:
			return 1
	return 0

		
		
