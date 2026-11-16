extends Area2D

@export var bounce_force: float = -1200.0 # Negative values move upward in Godot 2D

func _on_body_entered(body: Node2D) -> void:
	# Check if the object falling is the player
	if body.name == "Player": # Or use: if body is CharacterBody2D:
		body.velocity.y = bounce_force
