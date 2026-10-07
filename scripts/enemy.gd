extends CharacterBody2D

@export var SPEED = 50.0
@export var ATTACK_THRESHOLD = 20.0
@export var ATTACK_COOLDOWN = 500.0
@export var IDLE_TETHER_RADIUS = 50.0
@export var CHASING_TETHER_RADIUS = 200.0
@export var REACTION_TIME = 300.0
@export var BASIC_IMMUNE = false
@export var Y_OFFSET = 0.0


@export var ENEMY_TYPE = "test"
@export var DETECTION_RANGE = 100.0
@export var health = 100.0

@onready var collision_shape = $CollisionShape2D
@onready var animated_sprite = $AnimatedSprite2D
@onready var detection_area = $DetectionArea2D
@onready var detection_shape = $DetectionArea2D/CollisionShape2D
@onready var health_bar = $HealthBar

var start_pos: Vector2
var ai_state: String = "idling"
var chasing_target: Node2D
var chasing_target_delayed_pos: Vector2
var targets_in_range: Array[Node2D]
var direction: int = 1
var attack_timer: float = 0.0

func _ready() -> void:
	animated_sprite.play(ENEMY_TYPE)
	animated_sprite.offset.y += Y_OFFSET
	add_to_group("enemies")
	start_pos = position
	detection_shape.shape.radius = DETECTION_RANGE
	health_bar.max_value = health
	health_bar.value = health

func _physics_process(delta: float) -> void:
	_handle_gravity(delta)
	_handle_reaction_time(delta)
	_handle_movement(delta)
	_handle_health()
	_handle_attack_timer(delta)
	_handle_sprite()
	
	move_and_slide()

func _handle_sprite() -> void:
	animated_sprite.flip_h = velocity.x > 0
func _handle_attack_timer(delta: float) -> void:
	attack_timer = max(attack_timer - delta, 0.0)
	
func _handle_health() -> void:
	health_bar.value = max(health, 0.0)
	
	if health <= 0.0:
		_handle_death()
	
func _handle_death() -> void:
	queue_free()

func _handle_reaction_time(delta: float) -> void:
	if not chasing_target:
		return
	
	var current_target_pos = chasing_target.global_position
	var wait_time = REACTION_TIME*0.001
	await get_tree().create_timer(wait_time).timeout
	chasing_target_delayed_pos = current_target_pos
	
func _handle_gravity(delta: float) -> void:
	if is_on_floor(): 
		return
		
	velocity += get_gravity() * delta
	
	
func _handle_movement(delta: float) -> void:
	ai_state = _decide_movement()
	match ai_state:
		"idling":
			_move_idle(delta)
		"chasing":
			_move_chasing(delta)
		"attacking":
			_action_attack(delta)
			
func _decide_movement() -> String:
	if chasing_target:
		var distance_to_target = global_position.distance_to(chasing_target.global_position)
		if distance_to_target >= CHASING_TETHER_RADIUS:
			chasing_target = null
			return "idling"
		elif distance_to_target < ATTACK_THRESHOLD:
			return "attacking"
		return "chasing"
		
	elif not targets_in_range.is_empty():
		var target_candidate = targets_in_range[0]
		var distance_to_candidate = global_position.distance_to(target_candidate.global_position)
		if distance_to_candidate < CHASING_TETHER_RADIUS:
			chasing_target = target_candidate
			return "chasing"
	return "idling"

func find_closest_target(pos: Vector2, targets: Array[Node2D]) -> Node2D:
	var min_distance: float
	var min_target: Node2D
	for target in targets:
		var distance = pos.distance_to(target.global_position)
		if distance < min_distance:
			min_distance = distance
			min_target = target
	return min_target

func _move_idle(delta: float) -> void:
	var distance_from_start = global_position.x - start_pos.x 
	if distance_from_start <= IDLE_TETHER_RADIUS*-1:
		animated_sprite.flip_h = false
		direction = 1
	elif distance_from_start >= IDLE_TETHER_RADIUS:
		animated_sprite.flip_h = true
		direction = -1

	if is_on_wall():
		animated_sprite.flip_h = not animated_sprite.flip_h
		direction = -1 if animated_sprite.flip_h else 1
		
	velocity.x = direction * SPEED
	
func _move_chasing(delta: float) -> void:
	if chasing_target_delayed_pos.x > global_position.x:
		animated_sprite.flip_h = false
		direction = 1
	else:
		animated_sprite.flip_h = true
		direction = -1
	
	if abs(chasing_target_delayed_pos.x - global_position.x) < 5:
		velocity.x = 0
	else:
		velocity.x = direction * SPEED
	
func _action_attack(delta: float) -> void:
	velocity.x = 0
	if attack_timer != 0.0:
		return
	
	attack_timer = ATTACK_COOLDOWN*0.001
	
	if global_position.distance_to(chasing_target.global_position) > ATTACK_THRESHOLD:
		return
	
	chasing_target.health -= 1


func _on_detection_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_in_group("players"):
		return
	targets_in_range.append(body)

func _on_detection_area_2d_body_exited(body: Node2D) -> void:
	if not (body in targets_in_range):
		return
	targets_in_range.erase(body)
