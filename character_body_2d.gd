extends CharacterBody2D

const SPEED := 500.0
const JUMP_VELOCITY := -575.0
const SECOND_JUMP_VELOCITY := -400.0
const DASH_SPEED := 1000.0
const DASH_DURATION := 0.18
const DASH_COOLDOWN := 0.7

@onready var animated_sprite = $AnimatedSprite2D
@onready var footstep_audio = get_node_or_null("FootstepAudio")

var jumps_left := 2
var dash_timer := 0.0
var dash_cooldown_timer := 0.0
var dash_direction := 1.0

func _physics_process(delta: float) -> void:
	dash_cooldown_timer = maxf(dash_cooldown_timer - delta, 0.0)

	if Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0.0:
		$DashSfx.play()
		var input_direction := Input.get_axis("left", "right")
		dash_direction = input_direction if input_direction != 0.0 else (-1.0 if animated_sprite.flip_h else 1.0)
		dash_timer = DASH_DURATION
		dash_cooldown_timer = DASH_COOLDOWN

	if dash_timer > 0.0:
		dash_timer = maxf(dash_timer - delta, 0.0)
		velocity = Vector2(dash_direction * DASH_SPEED, 0.0)
	else:
		if is_on_floor():
			jumps_left = 2
		else:
			velocity += get_gravity() * delta

		if Input.is_action_just_pressed("jump") and jumps_left > 0:
			$JumpSfx.play()
			velocity.y = JUMP_VELOCITY if jumps_left == 2 else SECOND_JUMP_VELOCITY
			jumps_left -= 1

		var direction := Input.get_axis("left", "right")
		velocity.x = direction * SPEED if direction != 0.0 else move_toward(velocity.x, 0.0, SPEED)
		update_animation(direction)
		update_footsteps(direction)

	if dash_timer > 0.0:
		animated_sprite.flip_h = dash_direction < 0.0
		animated_sprite.play("Dash")

	move_and_slide()

func update_animation(direction: float) -> void:
	if direction != 0.0:
		animated_sprite.flip_h = direction < 0.0

	if not is_on_floor() and velocity.y < 0.0 and animated_sprite.sprite_frames.has_animation("Jump"):
		animated_sprite.play("Jump")
	elif direction != 0.0 or not is_on_floor():
		animated_sprite.play("Fly")
	else:
		animated_sprite.play("Idle")

func update_footsteps(direction: float) -> void:
	if footstep_audio == null:
		return

	if direction != 0.0 and is_on_floor():
		if not footstep_audio.playing:
			footstep_audio.play()
	else:
		footstep_audio.stop()
