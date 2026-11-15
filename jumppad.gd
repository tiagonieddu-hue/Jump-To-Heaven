
extends Area2D

@export var launch_speed: float = 900.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		body.velocity.y = -launch_speed
		$"../Bounce".play()
