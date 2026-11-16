
extends Node2D

var rng = RandomNumberGenerator.new()

var event_timer: float = 12.0
var event_duration: float = 0.0
var current_event: String = ""
var message_text: String = ""

var time_passed: float = 0.0


func _ready() -> void:
	rng.randomize()
	event_timer = rng.randf_range(10.0, 18.0)


func _process(delta: float) -> void:
	time_passed += delta

	event_timer -= delta

	if event_timer <= 0.0 and current_event == "":
		start_random_event()
		event_timer = rng.randf_range(15.0, 22.0)

	if current_event != "":
		event_duration -= delta

		if event_duration <= 0.0:
			current_event = ""

	queue_redraw()


func start_random_event() -> void:
	var events = ["flicker", "message", "static"]
	current_event = events[rng.randi_range(0, events.size() - 1)]

	match current_event:
		"flicker":
			event_duration = 1.5

		"message":
			event_duration = 4.0

			var messages = [
				"You weren't supposed to find this.",
				"Someone was here before you.",
				"Don't look behind you.",
				"The coins remember.",
				"Have we met before?",
				"Something moved in the trees."
			]

			message_text = messages[
				rng.randi_range(0, messages.size() - 1)
			]

		"static":
			event_duration = 1.0


func _draw() -> void:
	var screen_size = get_viewport_rect().size

	match current_event:
		"flicker":
			draw_flicker(screen_size)

		"message":
			draw_strange_message(screen_size)

		"static":
			draw_static(screen_size)


func draw_flicker(screen_size: Vector2) -> void:
	if absf(sin(time_passed * 19.0)) > 0.72:
		draw_rect(
			Rect2(Vector2.ZERO, screen_size),
			Color(0.0, 0.0, 0.0, 0.16)
		)


func draw_strange_message(screen_size: Vector2) -> void:
	var font = ThemeDB.fallback_font

	if font == null:
		return

	var font_size = 30

	var text_width = font.get_string_size(
		message_text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		font_size
	).x

	var panel_width = minf(
		text_width + 70.0,
		screen_size.x - 30.0
	)

	var panel_height = 68.0
	var panel_x = (screen_size.x - panel_width) / 2.0
	var panel_y = screen_size.y - 115.0

	draw_rect(
		Rect2(
			panel_x - 4,
			panel_y - 4,
			panel_width + 8,
			panel_height + 8
		),
		Color(0.35, 0.015, 0.04, 0.25)
	)

	draw_rect(
		Rect2(panel_x, panel_y, panel_width, panel_height),
		Color(0.015, 0.018, 0.035, 0.92)
	)

	draw_rect(
		Rect2(panel_x, panel_y, panel_width, panel_height),
		Color(0.55, 0.12, 0.17, 0.8),
		false,
		2.0
	)

	draw_string(
		font,
		Vector2(
			screen_size.x / 2.0 - text_width / 2.0,
			panel_y + 43
		),
		message_text,
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		font_size,
		Color(0.95, 0.88, 0.88)
	)


func draw_static(screen_size: Vector2) -> void:
	for i in range(65):
		var x = rng.randf_range(0.0, screen_size.x)
		var y = rng.randf_range(0.0, screen_size.y)

		draw_line(
			Vector2(x, y),
			Vector2(
				x + rng.randf_range(3.0, 20.0),
				y
			),
			Color(1.0, 1.0, 1.0, 0.25),
			1.0
		)
