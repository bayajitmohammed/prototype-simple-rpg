extends CharacterBody2D

@export var speed: float = 200.0

@onready var sprite = $AnimatedSprite2D

var direction = Vector2.ZERO
var last_direction = "up"
var is_attacking = false

func _physics_process(delta):
	if is_attacking:
		return

	var x = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y = Input.get_action_strength("down") - Input.get_action_strength("up")

	# No diagonal
	if x != 0:
		direction = Vector2(sign(x), 0)
	elif y != 0:
		direction = Vector2(0, sign(y))
	else:
		direction = Vector2.ZERO

	# Save last direction
	if direction != Vector2.ZERO:
		last_direction = get_direction_name(direction)

	velocity = direction * speed
	move_and_slide()

	update_animation()


func update_animation():
	if direction == Vector2.ZERO:
		play_anim("idle_" + last_direction)
	else:
		play_anim("walk_" + last_direction)


func play_anim(name: String):
	if sprite.animation != name:
		sprite.play(name)


func get_direction_name(dir: Vector2) -> String:
	if dir == Vector2.RIGHT:
		return "right"
	elif dir == Vector2.LEFT:
		return "left"
	elif dir == Vector2.UP:
		return "up"
	else:
		return "down"


# Attack input
func _input(event):
	if event.is_action_pressed("attack") and not is_attacking:
		is_attacking = true
		play_anim("attack_" + last_direction)


func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation.begins_with("attack"):
		is_attacking = false
