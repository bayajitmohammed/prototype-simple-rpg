extends CharacterBody2D

@export var texture: Texture2D
@export var speed: float = 100.0
@export var chase_range: float = 250.0
@export var attack_range: float = 80.0
@export var attack_cooldown: float = 1.5
@export var attack_damage: int = 10
@export var max_health: int = 4
var can_attack: bool = true
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var sprite: Sprite2D = $Sprite2D

var player: CharacterBody2D

var last_direction: Vector2 = Vector2(0,-1)
var attacking = false
var dying = false
var health: int = 4

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	health = max_health
	if texture:
		sprite.texture = texture
		

func _physics_process(delta: float) -> void:
	if !player or attacking or dying:
		return
		
	var diff = player.global_position - global_position
	var distance = diff.length()
	var direction = diff.normalized()
	
	velocity = Vector2.ZERO
	if distance <= attack_range:
		if can_attack:
			start_attack_animation()
	elif distance <= chase_range:
		velocity = direction * speed
		move_and_slide()
		if velocity.length() > 0:
			last_direction = direction
	
	animation_tree.set("parameters/Idle/blend_position", last_direction)
	animation_tree.set("parameters/Walk/blend_position", last_direction)
	animation_tree.set("parameters/Attack/blend_position", last_direction)
	
func start_attack_animation():
	attacking = true
	can_attack = false
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
	
func hit_enemy():
	health -= 1
	health = max(health, 0)
	attacking = false
	if health <= 0:
		dying = true
		
func play_hit_flash():
	var mat = sprite.material
	
	if not mat:
		return
	
	var tween = create_tween()
	tween.tween_property(mat, "shader_parameter/flash_value", 1.0, 0.05)
	tween.tween_property(mat, "shader_parameter/flash_value", 0.0, 0.1)
	
	

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name.contains("attack"):
		attacking = false
	if anim_name.contains("death"):
		dying = false
		queue_free()


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.hit_player(attack_damage)
