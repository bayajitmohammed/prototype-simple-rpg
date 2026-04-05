extends CharacterBody2D

@export var attack_damage: int = 10
@export var speed = 400
var direction = Vector2.ZERO

func _physics_process(delta):
	velocity = direction * speed
	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.hit_player(attack_damage)
		queue_free()
