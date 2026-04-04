extends CharacterBody2D

@export var speed: float = 200.0
@onready var animation_tree: AnimationTree = $AnimationTree

@onready var camera_2d: Camera2D = $Camera2D

var direction = Vector2.ZERO
var last_direction: Vector2 = Vector2(0,-1)

var attacking = false

var noise = FastNoiseLite.new()


func _physics_process(_delta):
	
	
	direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed
	if !attacking:
		move_and_slide()
	
	
	if velocity:
		last_direction = direction
	
	if Input.is_action_pressed("attack"):
		attacking = true
	animation_tree.set("parameters/Idle/blend_position", last_direction)
	animation_tree.set("parameters/Walk/blend_position", last_direction)
	animation_tree.set("parameters/Attack/blend_position", last_direction)

func frame_freeze(timescale:float, duration: float) -> void:
	Engine.time_scale = timescale
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0



func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name.contains("attack"):
		attacking = false


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.name == "Soldier":
		camera_2d.screen_shake(8, 0.5)
		frame_freeze(0.2, 0.3)
		body.hit_enemy()
