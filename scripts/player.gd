extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

# Movement settings
const MOVEMENT_SPEED = 130.0
const JUMP_VELOCITY = -400.0
const LAUNCH_VELOCITY = 750.0
const WALL_SLOWDOWN = 0.8
const FALLING_ATTACK_VELOCITY = 200.0

# Coyote time
const COYOTE_TIME = 0.10
var coyote_timer = 0.0

# Animations
const ANIMATION_STATES = {
	"idling": "idle",
	"climbing": "climb",
	"falling": "jump",
	"jumping": "jump",
	"walking": "walk"
}

const PRIMARY_ATTACKS = [
	"attack_slash_down",
	"attack_slash_up"
]

const SECONDARY_ATTACK = "attack_cast"

const FALLING_ATTACK = {
	"falling": "attack_fall_fall",
	"landing": "attack_fall_land"
}

# Player state
var stick_to_wall = true
var current_state = "idling"
var current_action = ""
var current_direction = 0

# Init
func _ready() -> void:
	animated_sprite.animation_finished.connect(
		_on_animation_finished
	)

# Physics
func _physics_process(delta: float) -> void:
	_handle_coyote_time(delta)
	_handle_gravity(delta)
	_handle_jump()
	_handle_movement(delta)
	
	move_and_slide()
	
	_update_state()
	_update_actions()
	_update_sprite()

func _handle_coyote_time(delta: float) -> void:
	if (
		is_on_floor()
		or is_on_wall()
		and stick_to_wall
	):
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer = max(coyote_timer - delta, 0.0)
		
func _handle_gravity(delta: float) -> void:
	if is_on_floor(): 
		return
		
	if (
		is_on_wall()
		and stick_to_wall
		and current_action != "falling_attack"
	):
		velocity.y *= WALL_SLOWDOWN
		return
	
	if not is_on_wall():
		stick_to_wall = true
		
	velocity += get_gravity() * delta

func _handle_jump() -> void:
	if not Input.is_action_just_pressed("jump"):
		return
		
	if is_on_wall() and stick_to_wall:
		var launch_direction = -_get_wall_direction()
		velocity = Vector2(
			LAUNCH_VELOCITY * launch_direction,
			JUMP_VELOCITY
		)
		
		stick_to_wall = false
		coyote_timer = 0.0
		return
	
	if coyote_timer > 0.0:
		velocity.y = JUMP_VELOCITY
		coyote_timer = 0.0

func _handle_movement(delta: float) -> void:
	var direction = 0.0
	
	if current_action != "falling_attack":
		direction = Input.get_axis("left", "right")
		
	if direction != 0.0:
		velocity.x = direction * MOVEMENT_SPEED
	else:
		velocity.x = move_toward(
			velocity.x,
			0.0,
			MOVEMENT_SPEED
		)
	
	if Input.is_action_just_pressed("down"):
		if is_on_wall() and stick_to_wall:
			stick_to_wall = false
	
# State
func _update_state() -> void:
	var wall_direction = _get_wall_direction()
	var input_direction = Input.get_axis("left", "right")
	
	current_direction = (
		float(wall_direction)
		if wall_direction != 0
		else input_direction
	)
	
	if is_on_wall() and stick_to_wall:
		current_state = "climbing"
		
	elif not is_on_floor():
		current_state = "falling"

	elif current_direction != 0.0:
		current_state = "walking"
		
	else:
		current_state = "idling"

# Actions
func _update_actions() -> void:
	if not current_action.is_empty():
		return
		
	if current_state == "climbing":
		return
	
	if Input.is_action_just_pressed("primary"):
		_start_action("primary_attack")
	
	elif Input.is_action_just_pressed("secondary"):
		_start_action("secondary_attack")
			
	elif (
		Input.is_action_pressed("down")
		and current_state == "falling"
	):
		_start_action("falling_attack")
		
func _start_action(action: String) -> void:
	current_action = action
	
	match action:
		"primary_attack":
			_play_animation(PRIMARY_ATTACKS.pick_random())
		
		"secondary_attack":
			_play_animation(SECONDARY_ATTACK)
		
		"falling_attack":
			_play_animation(FALLING_ATTACK["falling"])
			velocity.y = max(
				FALLING_ATTACK_VELOCITY + velocity.y, 
				FALLING_ATTACK_VELOCITY
			)
				
func _on_animation_finished() -> void:
	if current_action.is_empty():
		return
			
	current_action = ""

# Sprite and animation
func _update_sprite() -> void:
	if current_direction != 0.0:
		animated_sprite.flip_h = current_direction < 0.0
	
	if not current_action.is_empty():
		_update_active_action()
		return
		
	_play_animation(ANIMATION_STATES[current_state])
		
func _update_active_action() -> void:
	match current_action:
		"falling_attack":
			if (
				is_on_floor()
				and animated_sprite.animation == FALLING_ATTACK["falling"]
			):
				_play_animation(FALLING_ATTACK["landing"])
				VfxPlayer.play_vfx("directional_impact_002_small_white", position)
				
		"secondary_attack":
			if animated_sprite.frame == 4:
				VfxPlayer.play_vfx("symmetrical_impact_002_large_blue", position)
	
		
func _play_animation(animation_name: String) -> void:
	if animated_sprite.animation == animation_name:
		return
	
	animated_sprite.play(animation_name)

# Wall detection
func _get_wall_direction() -> int:
	if not is_on_wall(): 
		return 0
	
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var normal_x = collision.get_normal().x
		
		if normal_x > 0.0:
			return -1
			
		elif normal_x < 0.0:
			return 1
			
	return 0
