extends CharacterBody2D

const BASE_SPEED = 900.0
const SPEED_BOOST_PER_LEVEL = 150.0
const JUMP_VELOCITY = -900.0
const FALL_LIMIT = 1500.0
const FALL_BOUNCE_FORCE = -2500.0
const MAX_FALL_BOUNCES = 5
const GAME_OVER_Y = 2500.0
const MAX_JUMPS = 2

# Dash & Ghost Trail Settings
const DASH_MULTIPLIER = 1.5 # Lowered from 2.5 for a slower, more controlled dash
const DASH_DURATION = 0.2
const DASH_COOLDOWN = 3.0
const GHOST_SPAWN_INTERVAL = 0.025
const GHOST_FADE_DURATION = 0.3
const GHOST_TINT = Color(0.4, 0.85, 1.0, 0.75)

var level: int = 1
var coins: int = 0
var coins_to_next_level: int = 2
var speed: float = BASE_SPEED
var jump_count: int = 0

var start_position: Vector2
var fall_bounce_cooldown: float = 0.0
var fall_bounce_count: int = 0

# Dash state variables
var last_aim_direction: Vector2 = Vector2.RIGHT
var current_dash_direction: Vector2 = Vector2.RIGHT
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var ghost_spawn_timer: float = 0.0

# Finds Sprite2D, AnimatedSprite2D, ColorRect, or Polygon2D automatically
@onready var visual_node: CanvasItem = _find_visual_node()

func _ready() -> void:
	start_position = global_position

func _physics_process(delta: float) -> void:
	# Update cooldowns
	if fall_bounce_cooldown > 0:
		fall_bounce_cooldown -= delta
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	# Launch Mario very high if he falls off the map (up to 5 times).
	if global_position.y > FALL_LIMIT and fall_bounce_cooldown <= 0:
		if fall_bounce_count < MAX_FALL_BOUNCES:
			fall_bounce_count += 1
			velocity.y = FALL_BOUNCE_FORCE
			fall_bounce_cooldown = 0.5
			jump_count = 1
			dash_timer = 0.0
			print("Fall save used: ", fall_bounce_count, "/", MAX_FALL_BOUNCES)
		elif global_position.y > GAME_OVER_Y:
			get_tree().reload_current_scene()
			return

	# Read 8-directional input
	var input_dir := Input.get_vector("left", "right", "up", "down")
	if input_dir != Vector2.ZERO:
		last_aim_direction = input_dir.normalized()

	# Trigger 8-directional dash
	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0 and dash_timer <= 0:
		dash_timer = DASH_DURATION
		dash_cooldown_timer = DASH_COOLDOWN
		current_dash_direction = last_aim_direction
		ghost_spawn_timer = 0.0

	if dash_timer > 0:
		dash_timer -= delta
		ghost_spawn_timer -= delta

		if ghost_spawn_timer <= 0:
			spawn_ghost()
			ghost_spawn_timer = GHOST_SPAWN_INTERVAL

		velocity = current_dash_direction * (speed * DASH_MULTIPLIER)
	else:
		# Add gravity and reset jumps on the floor.
		if not is_on_floor():
			velocity += get_gravity() * delta
		else:
			jump_count = 0

		# Handle jump and double jump.
		if Input.is_action_just_pressed("jump") and jump_count < MAX_JUMPS:
			velocity.y = JUMP_VELOCITY
			jump_count += 1

		# Handle normal horizontal movement.
		var horizontal_dir := Input.get_axis("left", "right")
		if horizontal_dir:
			velocity.x = horizontal_dir * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()

func spawn_ghost() -> void:
	if not visual_node:
		return

	var ghost: CanvasItem

	# Clone the exact look of your player visual node
	if visual_node is Sprite2D:
		var s := Sprite2D.new()
		s.texture = visual_node.texture
		s.hframes = visual_node.hframes
		s.vframes = visual_node.vframes
		s.frame = visual_node.frame
		s.flip_h = visual_node.flip_h
		s.flip_v = visual_node.flip_v
		s.global_position = visual_node.global_position
		s.global_rotation = visual_node.global_rotation
		s.global_scale = visual_node.global_scale
		ghost = s
	elif visual_node is AnimatedSprite2D:
		var s := Sprite2D.new()
		if visual_node.sprite_frames:
			s.texture = visual_node.sprite_frames.get_frame_texture(visual_node.animation, visual_node.frame)
		s.flip_h = visual_node.flip_h
		s.flip_v = visual_node.flip_v
		s.global_position = visual_node.global_position
		s.global_rotation = visual_node.global_rotation
		s.global_scale = visual_node.global_scale
		ghost = s
	elif visual_node is ColorRect:
		var r := ColorRect.new()
		r.size = visual_node.size
		r.global_position = visual_node.global_position
		r.global_rotation = visual_node.global_rotation
		r.global_scale = visual_node.global_scale
		ghost = r
	elif visual_node is Polygon2D:
		var p := Polygon2D.new()
		p.polygon = visual_node.polygon
		p.global_position = visual_node.global_position
		p.global_rotation = visual_node.global_rotation
		p.global_scale = visual_node.global_scale
		ghost = p
	else:
		return

	ghost.z_index = z_index - 1
	ghost.modulate = GHOST_TINT
	get_parent().add_child(ghost)

	# Fade out and remove automatically
	var tween := get_tree().create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, GHOST_FADE_DURATION)
	tween.tween_callback(ghost.queue_free)

func _find_visual_node() -> CanvasItem:
	for child in get_children():
		if child is Sprite2D or child is AnimatedSprite2D or child is ColorRect or child is Polygon2D:
			return child
	return null

func add_coin(amount: int = 1) -> void:
	coins += amount
	while coins >= coins_to_next_level:
		level_up()

func level_up() -> void:
	level += 1
	coins_to_next_level += 2
	speed = BASE_SPEED + (level - 1) * SPEED_BOOST_PER_LEVEL
	print("Level Up! Level: ", level, " | New Speed: ", speed)

func respawn() -> void:
	global_position = start_position
	velocity = Vector2.ZERO
	jump_count = 0
	dash_timer = 0.0
	dash_cooldown_timer = 0.0
