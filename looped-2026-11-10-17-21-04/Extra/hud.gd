extends CanvasLayer

var coins: int = 0
var has_won: bool = false
var is_game_over: bool = false
var game_started: bool = false

var time_left: float = 0.0
var timer_label: Label
var menu_overlay: ColorRect
var win_label: Label
var rainbow_hue: float = 0.0

func _ready() -> void:
	# Allow this UI to keep animating and receiving clicks while the game is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS
	$Label.visible = false
	_create_timer_label()
	_create_start_menu()
	get_tree().paused = true

func _process(delta: float) -> void:
	if has_won and win_label:
		rainbow_hue = fmod(rainbow_hue + delta * 0.8, 1.0)
		win_label.add_theme_color_override("font_color", Color.from_hsv(rainbow_hue, 0.9, 1.0))

	if game_started and not has_won and not is_game_over:
		time_left -= delta
		if time_left <= 0.0:
			time_left = 0.0
			_update_timer_label()
			_lose_game()
		else:
			_update_timer_label()

func _create_start_menu() -> void:
	menu_overlay = ColorRect.new()
	menu_overlay.color = Color(0.0, 0.0, 0.0, 0.75)
	menu_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(menu_overlay)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_overlay.add_child(center)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	center.add_child(vbox)

	var title := Label.new()
	title.text = "Select Difficulty"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 56)
	vbox.add_child(title)

	_add_difficulty_button(vbox, "Easy (4 Minutes)", 240.0)
	_add_difficulty_button(vbox, "Medium (3 Minutes)", 180.0)
	_add_difficulty_button(vbox, "Hard (2 Minutes)", 120.0)

func _add_difficulty_button(parent: VBoxContainer, label_text: String, seconds: float) -> void:
	var btn := Button.new()
	btn.text = label_text
	btn.custom_minimum_size = Vector2(320, 60)
	btn.add_theme_font_size_override("font_size", 28)
	btn.pressed.connect(_start_game.bind(seconds))
	parent.add_child(btn)

func _start_game(duration_seconds: float) -> void:
	time_left = duration_seconds
	game_started = true
	menu_overlay.queue_free()

	$Label.visible = true
	timer_label.visible = true
	_update_label()
	_update_timer_label()

	get_tree().paused = false

func _create_timer_label() -> void:
	timer_label = Label.new()
	timer_label.visible = false
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	timer_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT)
	timer_label.offset_left = -300
	timer_label.offset_top = 20
	timer_label.offset_right = -20
	timer_label.add_theme_font_size_override("font_size", 32)
	timer_label.add_theme_constant_override("outline_size", 4)
	timer_label.add_theme_color_override("font_outline_color", Color.BLACK)
	add_child(timer_label)

func _update_timer_label() -> void:
	var total_seconds := ceili(time_left)
	var minutes := total_seconds / 60
	var seconds := total_seconds % 60
	timer_label.text = "Time: %d:%02d" % [minutes, seconds]

func _on_coin_body_entered(body: Node2D) -> void:
	_collect_coin()

func _on_coin_2_body_entered(body: Node2D) -> void:
	_collect_coin()

func _collect_coin() -> void:
	if not game_started or has_won or is_game_over:
		return

	coins += 1
	_update_label()

	if coins >= 6:
		_end_game()

func _update_label() -> void:
	$Label.text = "Coins: " + str(coins)

func _show_center_banner(message: String, color: Color = Color.WHITE) -> Label:
	$Label.visible = false
	timer_label.visible = false

	var banner := Label.new()
	banner.text = message
	banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	banner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	banner.add_theme_font_size_override("font_size", 96)
	banner.add_theme_color_override("font_color", color)
	banner.add_theme_constant_override("outline_size", 8)
	banner.add_theme_color_override("font_outline_color", Color.BLACK)
	add_child(banner)
	return banner

func _end_game() -> void:
	has_won = true
	win_label = _show_center_banner("You Won!")
	get_tree().paused = true
	await get_tree().create_timer(2.0, true).timeout
	get_tree().quit()

func _lose_game() -> void:
	is_game_over = true
	_show_center_banner("Time's Up!", Color.RED)
	get_tree().paused = true
	await get_tree().create_timer(2.0, true).timeout
	get_tree().quit()
