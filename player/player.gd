extends CharacterBody2D

@export var speed: float = 200.0
@onready var animation_tree: AnimationTree = $AnimationTree

var direction = Vector2.ZERO
var last_direction: Vector2 = Vector2(0,-1)

var attacking = false

func _physics_process(delta):
	
	direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed
	move_and_slide()
	
	
	if velocity:
		last_direction = direction
	
	if Input.is_action_pressed("attack"):
		attacking = true
	animation_tree.set("parameters/Idle/blend_position", last_direction)
	animation_tree.set("parameters/Walk/blend_position", last_direction)
	animation_tree.set("parameters/Attack/blend_position", last_direction)


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name.contains("attack"):
		attacking = false
