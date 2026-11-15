extends Area2D

@export var pull_strength := 4000.0

func _physics_process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body is CharacterBody2D:
			var direction := (global_position - body.global_position).normalized()
			body.velocity += direction * pull_strength * delta
