
extends Label

var glitch_timer: float = 0.0
var glitch_duration: float = 0.0
var is_glitching: bool = false

var normal_title: String = "CoinCollector.Co"

var glitch_titles: Array[String] = [
	"CoinCollector.Co?",
	"CoinCollector...",
	"CoinCollector.Co_",
	"C0inCollector.Co",
	"CoinCollector.C0",
	"CoinCollector.Co!"
]


func _ready():
	text = normal_title
	glitch_timer = randf_range(5.0, 12.0)


func _process(delta):
	if not is_glitching:
		glitch_timer -= delta

		if glitch_timer <= 0.0:
			if randf() < 0.6:
				start_glitch()
			else:
				glitch_timer = randf_range(3.0, 6.0)
	else:
		glitch_duration -= delta

		if glitch_duration <= 0.0:
			end_glitch()


func start_glitch():
	is_glitching = true
	glitch_duration = randf_range(0.4, 1.2)

	text = glitch_titles.pick_random()

	modulate = Color("#FF7777")


func end_glitch():
	is_glitching = false
	text = normal_title
	modulate = Color.WHITE

	glitch_timer = randf_range(5.0, 12.0)
