extends CharacterBody2D

@export var speed: float = 200.0

@onready var sprite = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var direction = Vector2.ZERO
var last_direction = "up"
var is_attacking = false

func _physics_process(delta):
	if is_attacking:
		return

	var x = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y = Input.get_action_strength("down") - Input.get_action_strength("up")
	direction = Vector2(x, y)
	
	if direction != Vector2.ZERO:
		direction = direction.normalized()
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
	if animation_player.current_animation != name:
		animation_player.play("player/" + name)


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



func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name.contains("attack"):
		is_attacking = false
		play_anim("idle_" + last_direction)
