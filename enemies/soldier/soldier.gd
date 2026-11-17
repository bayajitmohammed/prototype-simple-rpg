extends CharacterBody2D

const ATTACK_SOUND: AudioStream = preload("res://sounds/effects/attack_swoosh_02.ogg")

@export var texture: Texture2D
@export var speed: float = 50.0
@export var chase_range: float = 100.0
@export var attack_range: float = 30.0
@export var attack_cooldown: float = 1.5
@export var attack_damage: int = 10
@export var max_health: int = 4
@export var wander_speed: float = 20.0
@export var wander_change_time: float = 2.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var sprite: Sprite2D = $Sprite2D

var player: CharacterBody2D

var last_direction: Vector2 = Vector2(0,-1)
var attacking = false
var dying = false
var health: int = 4
var can_attack: bool = true
var wander_direction: Vector2 = Vector2.ZERO
var wander_timer: float = 0.0
var hit_flash_tween: Tween


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	health = max_health
	if texture:
		sprite.texture = texture
		

func _physics_process(delta: float) -> void:
	if attacking or dying:
		return
	if not can_attack:
		velocity = Vector2.ZERO
		return
	
	var has_player = player != null
		
	if has_player:
		var diff = player.global_position - global_position
		var distance = diff.length()
		var direction = diff.normalized()
		
		velocity = Vector2.ZERO
		
		if distance <= attack_range:
			if can_attack:
				start_attack_animation()
		elif distance <= chase_range:
			velocity = direction * speed
			if velocity.length() > 0:
				last_direction = direction
		else:
			wander(delta)
	else:
		wander(delta)
	
	move_and_slide()
	
	animation_tree.set("parameters/Idle/blend_position", last_direction)
	animation_tree.set("parameters/Walk/blend_position", last_direction)
	animation_tree.set("parameters/Attack/blend_position", last_direction)
	
	
func wander(delta: float):
	wander_timer -= delta
	
	if wander_timer <= 0:
		wander_timer = wander_change_time
		wander_direction = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
	
	velocity = wander_direction * wander_speed
	
	if velocity.length() > 0:
		last_direction = wander_direction

	
func start_attack_animation():
	attacking = true
	velocity = Vector2.ZERO
	var playback: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
	playback.start(&"Attack", true)
	GameAudio.play(get_tree(), ATTACK_SOUND, -14.0)
	can_attack = false
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
	
func hit_enemy() -> bool:
	if dying or health <= 0:
		return false
	health = max(health - 1, 0)
	attacking = false
	if health <= 0:
		dying = true
		if hit_flash_tween and hit_flash_tween.is_running():
			hit_flash_tween.kill()
		if sprite.material:
			sprite.material.set_shader_parameter("flash_value", 0.0)
		$AttackArea.set_deferred("monitoring", false)
		$CollisionShape2D.set_deferred("disabled", true)
	return true
		
func play_hit_flash():
	if dying:
		return
	var mat = sprite.material
	if not mat:
		return
	if hit_flash_tween and hit_flash_tween.is_running():
		hit_flash_tween.kill()
	hit_flash_tween = create_tween()
	hit_flash_tween.tween_property(mat, "shader_parameter/flash_value", 1.0, 0.05)
	hit_flash_tween.tween_property(mat, "shader_parameter/flash_value", 0.0, 0.1)
	


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name.contains("attack"):
		attacking = false
	if anim_name.contains("death"):
		dying = false
		queue_free()


func _on_attack_area_body_entered(body: Node2D) -> void:
	if not dying and body.is_in_group("player"):
		body.hit_player(attack_damage)
