extends CharacterBody2D

@export var speed: float = 100.0
@export var chase_range: float = 250.0
@export var attack_range: float = 80.0
@export var attack_cooldown: float = 2.0
var can_attack: bool = true

@onready var animation_tree: AnimationTree = $AnimationTree
var player: CharacterBody2D

var last_direction: Vector2 = Vector2(0,-1)
var attacking = false

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if !player:
		return
	var diff = player.global_position - global_position
	var distance = diff.length()
	var direction = diff.normalized()
	
	velocity = Vector2.ZERO
	if distance <= attack_range:
		if can_attack:
			start_attack()
	elif distance <= chase_range:
		velocity = direction * speed
		move_and_slide()
		if velocity.length() > 0:
			last_direction = direction
	
	animation_tree.set("parameters/Idle/blend_position", last_direction)
	animation_tree.set("parameters/Walk/blend_position", last_direction)
	animation_tree.set("parameters/Attack/blend_position", last_direction)
	
func start_attack():
	attacking = true
	can_attack = false
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
	
func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name.contains("attack"):
		attacking = false
