
extends Node2D

var birds: Array[Vector2] = []
var butterflies: Array[Vector2] = []
var time_passed: float = 0.0

var spooky_timer: float = 0.0
var spooky_visible: bool = false
var spooky_elapsed: float = 0.0
var spooky_duration: float = 8.0
var spooky_alpha: float = 0.0

# Sun transformation
var sun_face_timer: float = 12.0
var sun_creepy_amount: float = 0.0

const GRASS_COUNT = 150
const BUTTERFLY_COUNT = 7


func _ready():
	randomize()

	for i in range(5):
		birds.append(Vector2(
			randf_range(0, 1152),
			randf_range(70, 250)
		))

	for i in range(BUTTERFLY_COUNT):
		if i == 1:
			butterflies.append(Vector2(
				randf_range(380, 1050),
				randf_range(390, 490)
			))
		else:
			butterflies.append(Vector2(
				randf_range(0, 1152),
				randf_range(400, 650)
			))

	spooky_timer = randf_range(18.0, 28.0)
	queue_redraw()


func _process(delta):
	time_passed += delta

	# Transform the sun's smile.
	if sun_creepy_amount < 1.0:
		sun_face_timer -= delta
		if sun_face_timer <= 0.0:
			sun_creepy_amount = minf(
				sun_creepy_amount + delta * 0.22,
				1.0
			)

	var screen_width = get_viewport_rect().size.x

	# Move birds
	for i in range(birds.size()):
		birds[i].x += 45.0 * delta

		if birds[i].x > screen_width + 30:
			birds[i].x = -30

	# Flutter butterflies
	for i in range(butterflies.size()):
		butterflies[i].x += sin(time_passed * 2.5 + i) * 28.0 * delta
		butterflies[i].y += cos(time_passed * 3.2 + i * 2.0) * 30.0 * delta

		if i == 1:
			butterflies[i].x = clampf(butterflies[i].x, 380.0, screen_width - 35.0)
			butterflies[i].y = clampf(butterflies[i].y, 380.0, 500.0)
		else:
			if butterflies[i].x > screen_width + 20:
				butterflies[i].x = -20

			if butterflies[i].x < -20:
				butterflies[i].x = screen_width + 20

	# Spooky figure timing
	if spooky_visible:
		spooky_elapsed += delta
		var fade_in_time = 0.8
		var fade_out_start = spooky_duration - 0.8

		if spooky_elapsed < fade_in_time:
			spooky_alpha = spooky_elapsed / fade_in_time
		elif spooky_elapsed > fade_out_start:
			spooky_alpha = clampf(
				(spooky_duration - spooky_elapsed) / 0.8,
				0.0,
				1.0
			)
		else:
			spooky_alpha = 1.0

		if spooky_elapsed >= spooky_duration:
			spooky_visible = false
			spooky_alpha = 0.0
			spooky_timer = randf_range(32.0, 48.0)
	else:
		spooky_timer -= delta
		if spooky_timer <= 0.0:
			spooky_visible = true
			spooky_elapsed = 0.0
			spooky_duration = randf_range(7.0, 9.0)

	queue_redraw()


func _draw():
	var w = get_viewport_rect().size.x
	var h = get_viewport_rect().size.y

	# SKY
	draw_rect(Rect2(0, 0, w, h), Color("#3989D8"))

	# SUN
	var sun_center = Vector2(w * 0.78, h * 0.23)

	draw_circle(
		sun_center,
		55,
		Color("#FFE18A")
	)

	draw_circle(
		sun_center,
		68,
		Color(1.0, 0.88, 0.55, 0.12)
	)

	# SUN FACE
	var face_amount = smoothstep(0.0, 1.0, sun_creepy_amount)
	var eye_color = Color("#49351F")

	# Eyes become narrower and more menacing.
	var eye_height = lerpf(3.5, 1.8, face_amount)
	var eye_width = lerpf(3.0, 5.0, face_amount)

	for eye_x in [-13.0, 13.0]:
		var eye_pos = sun_center + Vector2(eye_x, -8.0)
		draw_ellipse_shape(
			eye_pos,
			Vector2(eye_width, eye_height),
			eye_color
		)

	# Smile grows wider and deeper.
	var smile_width = lerpf(17.0, 29.0, face_amount)
	var smile_depth = lerpf(10.0, 18.0, face_amount)
	var smile_points := PackedVector2Array()

	for i in range(25):
		var t = float(i) / 24.0
		var x = lerpf(-smile_width, smile_width, t)
		var normalized_x = x / smile_width
		var y = 5.0 + (1.0 - normalized_x * normalized_x) * smile_depth

		smile_points.append(sun_center + Vector2(x, y))

	draw_polyline(
		smile_points,
		eye_color,
		lerpf(2.5, 4.0, face_amount),
		true
	)

	# Pointed teeth appear as the smile becomes creepy.
	if face_amount > 0.45:
		var tooth_alpha = clampf(
			(face_amount - 0.45) / 0.55,
			0.0,
			1.0
		)

		for i in range(9):
			var tooth_x = lerpf(-20.0, 20.0, float(i) / 8.0)
			var normalized_x = tooth_x / 29.0
			var mouth_y = 5.0 + (1.0 - normalized_x * normalized_x) * 18.0

			var tooth_top = sun_center + Vector2(tooth_x, mouth_y - 1.0)
			var tooth_tip = sun_center + Vector2(tooth_x + 1.5, mouth_y + 6.0)
			var tooth_side = sun_center + Vector2(tooth_x + 4.0, mouth_y - 1.0)

			draw_colored_polygon(
				PackedVector2Array([
					tooth_top,
					tooth_tip,
					tooth_side
				]),
				Color(1.0, 0.96, 0.78, tooth_alpha)
			)

	# CLOUDS
	for i in range(5):
		var x = fposmod(
			i * 270 + time_passed * 8,
			w + 200
		) - 100

		var y = 100 + (i % 2) * 65

		draw_circle(Vector2(x, y), 24, Color.WHITE)
		draw_circle(Vector2(x + 25, y - 10), 30, Color.WHITE)
		draw_circle(Vector2(x + 52, y), 23, Color.WHITE)

	# DISTANT MOUNTAINS
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(0, h * 0.52),
			Vector2(w * 0.18, h * 0.30),
			Vector2(w * 0.35, h * 0.53),
			Vector2(w * 0.57, h * 0.32),
			Vector2(w * 0.78, h * 0.53),
			Vector2(w, h * 0.35),
			Vector2(w, h),
			Vector2(0, h)
		]),
		Color("#596EAD")
	)

	# BACK HILL
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(0, h * 0.65),
			Vector2(w * 0.28, h * 0.47),
			Vector2(w * 0.52, h * 0.67),
			Vector2(w * 0.77, h * 0.48),
			Vector2(w, h * 0.63),
			Vector2(w, h),
			Vector2(0, h)
		]),
		Color("#4EAC69")
	)

	# WINDMILL
	draw_windmill(Vector2(w * 0.48, h * 0.59))

	# HOUSES
	draw_house(
		Vector2(w * 0.20, h * 0.56),
		0.85,
		Color("#F1B77A"),
		Color("#A64F45")
	)

	draw_house(
		Vector2(w * 0.67, h * 0.55),
		1.0,
		Color("#E8D29A"),
		Color("#7651A8")
	)

	draw_house(
		Vector2(w * 0.88, h * 0.61),
		0.65,
		Color("#B9D8A1"),
		Color("#A64F45")
	)

	# FRONT HILL
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(0, h * 0.79),
			Vector2(w * 0.25, h * 0.66),
			Vector2(w * 0.52, h * 0.80),
			Vector2(w * 0.78, h * 0.67),
			Vector2(w, h * 0.76),
			Vector2(w, h),
			Vector2(0, h)
		]),
		Color("#287C48")
	)

	# WINDING PATH
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(w * 0.35, h),
			Vector2(w * 0.49, h),
			Vector2(w * 0.58, h * 0.82),
			Vector2(w * 0.48, h * 0.73),
			Vector2(w * 0.39, h * 0.78)
		]),
		Color("#D9A56D")
	)

	# RIVER
	draw_river(w, h)

	# BRIDGE
	draw_bridge(Vector2(w * 0.57, h * 0.795))

	# SWAYING GRASS
	for i in range(GRASS_COUNT):
		var x = fposmod(i * 37.7, w)
		var base_y = h * 0.83 + fposmod(i * 19.3, h * 0.16)

		var wind = sin(
			time_passed * 2.5 + float(i) * 0.7
		) * 7.0

		var blade_height = 9.0 + fposmod(i * 13.7, 13.0)

		var grass_color = Color("#69C95A")

		if i % 3 == 0:
			grass_color = Color("#8BD65D")
		elif i % 3 == 1:
			grass_color = Color("#3D9E48")

		draw_line(
			Vector2(x, base_y),
			Vector2(x + wind, base_y - blade_height),
			grass_color,
			2
		)

	# FLOWERS
	for i in range(35):
		var x = fposmod(i * 97, w)
		var y = h * 0.84 + (i % 4) * 15

		draw_flower(Vector2(x, y), i)

	# BUTTERFLIES
	for i in range(butterflies.size()):
		draw_butterfly(butterflies[i], i)

	# BIRDS
	for i in range(birds.size()):
		var bird = birds[i]

		var flap = sin(
			time_passed * 12.0 + float(i) * 1.7
		) * 8.0

		var bird_color = Color("#182B48")

		draw_line(
			bird,
			bird + Vector2(-9, -flap),
			bird_color,
			3
		)

		draw_line(
			bird,
			bird + Vector2(9, -flap),
			bird_color,
			3
		)

		draw_rect(
			Rect2(bird.x - 2, bird.y - 1, 4, 3),
			bird_color
		)

	# TREES
	for i in range(4):
		var x = i * 95 + 25

		draw_rect(
			Rect2(x, h * 0.57, 15, 90),
			Color("#70452E")
		)

		draw_circle(
			Vector2(x + 7, h * 0.56),
			35,
			Color("#246C42")
		)

	# SPOOKY FIGURE - in front of the trees.
	if spooky_visible and spooky_alpha > 0.0:
		draw_spooky_figure(
			Vector2(w * 0.205, h * 0.755),
			spooky_alpha
		)


# =====================================
# DETAILED FLOWERS
# =====================================

func draw_flower(pos: Vector2, index: int):
	var sway = sin(time_passed * 2.5 + index) * 2.0
	var flower_pos = pos + Vector2(sway, 0)

	var petal_colors = [
		Color("#FF8DB3"),
		Color("#FFF0A6"),
		Color("#B9A0FF"),
		Color("#FFFFFF"),
		Color("#FFAA73")
	]

	var petal_color = petal_colors[index % petal_colors.size()]

	draw_line(
		flower_pos + Vector2(0, 4),
		flower_pos + Vector2(-1, 19),
		Color("#287C48"),
		2
	)

	draw_leaf_ellipse(
		flower_pos + Vector2(-5, 12),
		Vector2(5, 2.5),
		Color("#70C85A")
	)

	draw_leaf_ellipse(
		flower_pos + Vector2(5, 15),
		Vector2(5, 2.5),
		Color("#4EAC69")
	)

	for p in range(5):
		var angle = TAU * float(p) / 5.0

		var petal_pos = flower_pos + Vector2(
			cos(angle) * 5.0,
			sin(angle) * 5.0
		)

		draw_circle(petal_pos, 4.0, petal_color)

	draw_circle(flower_pos, 3.0, Color("#F5C542"))

	draw_circle(
		flower_pos + Vector2(-1, -1),
		1.0,
		Color("#FFF5B5")
	)


# =====================================
# CUSTOM ELLIPSE DRAWING
# =====================================

func draw_leaf_ellipse(pos: Vector2, radius: Vector2, color: Color):
	var points = PackedVector2Array()

	for i in range(13):
		var angle = TAU * float(i) / 12.0

		points.append(pos + Vector2(
			cos(angle) * radius.x,
			sin(angle) * radius.y
		))

	draw_colored_polygon(points, color)


# =====================================
# ANIMATED BUTTERFLY
# =====================================

func draw_butterfly(pos: Vector2, index: int):
	var wing_flap = abs(
		sin(time_passed * 11.0 + index)
	) * 7.0

	var colors = [
		Color("#FF8DB3"),
		Color("#FFE17A"),
		Color("#A9A0FF"),
		Color("#80E6D0"),
		Color("#FFAD73")
	]

	var wing_color = colors[index % colors.size()]

	draw_leaf_ellipse(
		pos + Vector2(-wing_flap * 0.5 - 3, 0),
		Vector2(5, 7),
		wing_color
	)

	draw_leaf_ellipse(
		pos + Vector2(wing_flap * 0.5 + 3, 0),
		Vector2(5, 7),
		wing_color
	)

	draw_line(
		pos + Vector2(0, -5),
		pos + Vector2(0, 6),
		Color("#493A4D"),
		2
	)

	draw_line(
		pos,
		pos + Vector2(-4, -6),
		Color("#493A4D"),
		1
	)

	draw_line(
		pos,
		pos + Vector2(4, -6),
		Color("#493A4D"),
		1
	)


# =====================================
# ANIMATED RIVER
# =====================================

func draw_river(w: float, h: float):
	var river_points = PackedVector2Array()

	for i in range(13):
		var x = w * float(i) / 12.0
		var y = h * 0.78 + sin(float(i) * 0.55) * h * 0.055

		river_points.append(Vector2(x, y))

	draw_polyline(
		river_points,
		Color("#397C55"),
		67,
		true
	)

	draw_polyline(
		river_points,
		Color("#369DD2"),
		53,
		true
	)

	draw_polyline(
		river_points,
		Color("#55BCE5"),
		35,
		true
	)

	for i in range(17):
		var x = fposmod(
			i * 91.0 + time_passed * 45.0,
			w
		)

		var y = h * 0.78 + sin(
			(x / w) * 6.0 + 0.2
		) * h * 0.055

		var ripple_length = 8.0 + float(i % 4) * 3.0

		draw_line(
			Vector2(x, y - 5),
			Vector2(x + ripple_length, y - 5),
			Color(0.82, 0.95, 1.0, 0.7),
			2
		)

	for i in range(9):
		var x = fposmod(
			i * 137.0 + time_passed * 25.0,
			w
		)

		var y = h * 0.78 + sin(
			(x / w) * 6.0 + 0.2
		) * h * 0.055

		draw_circle(
			Vector2(x, y + 8),
			2,
			Color(0.9, 0.98, 1.0, 0.8)
		)


# =====================================
# WOODEN BRIDGE
# =====================================

func draw_bridge(center: Vector2):
	var x = center.x
	var y = center.y

	draw_rect(
		Rect2(x - 83, y + 12, 166, 12),
		Color("#285B43")
	)

	draw_rect(
		Rect2(x - 69, y + 2, 10, 31),
		Color("#70452E")
	)

	draw_rect(
		Rect2(x + 59, y + 2, 10, 31),
		Color("#70452E")
	)

	draw_rect(
		Rect2(x - 85, y - 7, 170, 14),
		Color("#9B633D")
	)

	for i in range(10):
		var plank_x = x - 81 + i * 18

		draw_rect(
			Rect2(plank_x, y - 6, 16, 12),
			Color("#BD8551")
		)

		draw_line(
			Vector2(plank_x + 2, y - 4),
			Vector2(plank_x + 2, y + 4),
			Color("#805235"),
			1
		)

	for i in range(9):
		var post_x = x - 80 + i * 20

		draw_rect(
			Rect2(post_x, y - 35, 6, 29),
			Color("#805235")
		)

		draw_rect(
			Rect2(post_x - 2, y - 38, 10, 5),
			Color("#C18A55")
		)

	draw_rect(
		Rect2(x - 88, y - 39, 176, 7),
		Color("#A96F43")
	)

	draw_rect(
		Rect2(x - 84, y - 23, 168, 5),
		Color("#805235")
	)

	draw_line(
		Vector2(x - 83, y - 36),
		Vector2(x + 83, y - 36),
		Color("#D5A16A"),
		2
	)


# =====================================
# WINDMILL
# =====================================

func draw_windmill(base: Vector2):
	var x = base.x
	var y = base.y

	draw_colored_polygon(
		PackedVector2Array([
			Vector2(x - 16, y + 37),
			Vector2(x - 9, y - 24),
			Vector2(x + 9, y - 24),
			Vector2(x + 16, y + 37)
		]),
		Color("#E8D7B5")
	)

	draw_line(
		Vector2(x - 16, y + 37),
		Vector2(x - 9, y - 24),
		Color("#92775C"),
		2
	)

	draw_line(
		Vector2(x + 16, y + 37),
		Vector2(x + 9, y - 24),
		Color("#92775C"),
		2
	)

	draw_rect(
		Rect2(x - 5, y + 15, 10, 22),
		Color("#805235")
	)

	var rotor = Vector2(x, y - 27)

	for i in range(4):
		var angle = time_passed * 1.4 + i * PI / 2.0

		var direction = Vector2(
			cos(angle),
			sin(angle)
		)

		var end = rotor + direction * 43.0

		draw_line(
			rotor,
			end,
			Color("#70452E"),
			6
		)

		var side = Vector2(
			-direction.y,
			direction.x
		) * 5.0

		draw_colored_polygon(
			PackedVector2Array([
				rotor + direction * 8.0 - side,
				end - side,
				end + side,
				rotor + direction * 8.0 + side
			]),
			Color("#F5E6C7")
		)

	draw_circle(rotor, 7, Color("#A64F45"))
	draw_circle(rotor, 3, Color("#F6D58C"))


# =====================================
# HOUSE DRAWING
# =====================================

func draw_house(
	base: Vector2,
	scale_factor: float,
	wall_color: Color,
	roof_color: Color
):
	var x = base.x
	var y = base.y
	var s = scale_factor

	draw_rect(
		Rect2(x - 8 * s, y + 1 * s, 100 * s, 8 * s),
		Color("#246B43")
	)

	draw_rect(
		Rect2(x + 65 * s, y - 80 * s, 13 * s, 35 * s),
		Color("#A64F45")
	)

	draw_rect(
		Rect2(x + 62 * s, y - 82 * s, 19 * s, 6 * s),
		Color("#713E3C")
	)

	draw_colored_polygon(
		PackedVector2Array([
			Vector2(x - 12 * s, y - 48 * s),
			Vector2(x + 42 * s, y - 100 * s),
			Vector2(x + 96 * s, y - 48 * s)
		]),
		roof_color
	)

	draw_rect(
		Rect2(x, y - 50 * s, 84 * s, 58 * s),
		wall_color
	)

	draw_rect(
		Rect2(x + 34 * s, y - 35 * s, 20 * s, 43 * s),
		Color("#70452E")
	)

	draw_circle(
		Vector2(x + 49 * s, y - 15 * s),
		2 * s,
		Color("#FFE18A")
	)

	draw_rect(
		Rect2(x + 9 * s, y - 39 * s, 18 * s, 18 * s),
		Color("#A8DDF2")
	)

	draw_rect(
		Rect2(x + 59 * s, y - 39 * s, 17 * s, 18 * s),
		Color("#A8DDF2")
	)

	draw_rect(
		Rect2(x + 17 * s, y - 39 * s, 3 * s, 18 * s),
		Color("#70452E")
	)

	draw_rect(
		Rect2(x + 9 * s, y - 31 * s, 18 * s, 3 * s),
		Color("#70452E")
	)

	draw_line(
		Vector2(x - 12 * s, y - 48 * s),
		Vector2(x + 42 * s, y - 100 * s),
		Color("#593A35"),
		3
	)

	draw_line(
		Vector2(x + 42 * s, y - 100 * s),
		Vector2(x + 96 * s, y - 48 * s),
		Color("#593A35"),
		3
	)

	for i in range(4):
		var progress = fposmod(
			time_passed * 0.28 + float(i) * 0.25,
			1.0
		)

		var smoke_x = x + 71 * s + sin(
			time_passed * 2.0 + float(i)
		) * 7.0 * s

		var smoke_y = y - 85 * s - progress * 45 * s

		var alpha = (1.0 - progress) * 0.38

		var smoke_color = Color(
			0.85, 0.88, 0.91, alpha
		)

		draw_circle(
			Vector2(smoke_x, smoke_y),
			(4.0 + progress * 5.0) * s,
			smoke_color
		)


# =====================================
# DISTANT SPOOKY FIGURE
# =====================================

func draw_spooky_figure(base: Vector2, alpha: float) -> void:
	var shadow_color = Color(0.025, 0.025, 0.045, 0.92 * alpha)
	var hood_color = Color(0.012, 0.012, 0.025, 0.98 * alpha)
	var face_color = Color(0.32, 0.34, 0.39, 0.55 * alpha)

	# Long coat
	draw_colored_polygon(
		PackedVector2Array([
			base + Vector2(-19, -72),
			base + Vector2(18, -72),
			base + Vector2(25, -8),
			base + Vector2(18, 0),
			base + Vector2(-22, 0),
			base + Vector2(-26, -8)
		]),
		shadow_color
	)

	# Head and hood
	draw_circle(base + Vector2(0, -83), 15, hood_color)

	draw_colored_polygon(
		PackedVector2Array([
			base + Vector2(-15, -82),
			base + Vector2(-10, -101),
			base + Vector2(2, -108),
			base + Vector2(15, -96),
			base + Vector2(17, -80),
			base + Vector2(8, -72),
			base + Vector2(-11, -73)
		]),
		hood_color
	)

	# Face
	draw_ellipse_shape(
		base + Vector2(1, -84),
		Vector2(6, 9),
		face_color
	)

	# Arms
	draw_line(
		base + Vector2(-17, -66),
		base + Vector2(-29, -27),
		shadow_color,
		9.0
	)

	draw_line(
		base + Vector2(17, -66),
		base + Vector2(29, -30),
		shadow_color,
		9.0
	)

	# Legs and shoes
	draw_line(
		base + Vector2(-10, -5),
		base + Vector2(-13, 13),
		shadow_color,
		10.0
	)

	draw_line(
		base + Vector2(10, -5),
		base + Vector2(13, 13),
		shadow_color,
		10.0
	)

	draw_line(
		base + Vector2(-13, 13),
		base + Vector2(-21, 14),
		shadow_color,
		7.0
	)

	draw_line(
		base + Vector2(13, 13),
		base + Vector2(21, 14),
		shadow_color,
		7.0
	)


# =====================================
# ELLIPSE SHAPE
# =====================================

func draw_ellipse_shape(pos: Vector2, radius: Vector2, color: Color) -> void:
	var points := PackedVector2Array()

	for i in range(17):
		var angle := TAU * float(i) / 16.0

		points.append(pos + Vector2(
			cos(angle) * radius.x,
			sin(angle) * radius.y
		))

	draw_colored_polygon(points, color)
