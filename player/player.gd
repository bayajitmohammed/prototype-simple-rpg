extends CharacterBody2D

@export var speed: float = 100.0
@export var max_health: int = 100
@onready var animation_tree: AnimationTree = $AnimationTree

@onready var camera_2d: Camera2D = $Camera2D
@onready var health_bar: ProgressBar = $HealthBar

var direction = Vector2.ZERO
var last_direction: Vector2 = Vector2(0,-1)

var attacking = false
var dying = false
var health: int = 100

var noise = FastNoiseLite.new()

func _ready() -> void:
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = health

func  _process(_delta: float) -> void:
	health_bar.visible = health < max_health

func _physics_process(_delta):
	if attacking or dying:
		return
	
	direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed
	move_and_slide()
	
	
	if velocity:
		last_direction = direction
	
	animation_tree.set("parameters/Idle/blend_position", last_direction)
	animation_tree.set("parameters/Walk/blend_position", last_direction)
	animation_tree.set("parameters/Attack/blend_position", last_direction)

	if Input.is_action_just_pressed("attack"):
		attacking = true
		# Explicitly (re)start the Attack state. Relying only on the "attacking"
		# advance expression can leave the tree parked on the last frame of a
		# finished attack, so animation_finished never fires again.
		var playback: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
		playback.start(&"Attack", true)

func frame_freeze(timescale: float, duration: float) -> void:
	var tree: SceneTree = get_tree()
	if tree == null:
		return
	Engine.time_scale = timescale
	# The reset is connected to Engine itself, not to this node, so time_scale is
	# restored even if the player is freed by a scene change mid-freeze.
	tree.create_timer(duration, true, false, true).timeout.connect(Engine.set.bind("time_scale", 1.0))
	
func hit_player(damage: int):
	health -= damage
	health = max(health, 0)
	update_health_bar()
	if health <= 0:
		dying = true

func update_health_bar():
	var tween = create_tween()
	tween.tween_property(health_bar, "value", health, 0.2)
	
func heal_to_full():
	health = max_health
	update_health_bar()

func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name.contains("attack"):
		attacking = false
	if anim_name.contains("death"):
		dying = false
		get_tree().change_scene_to_file("res://ui/death/death.tscn")



func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.has_method("hit_enemy"):
		camera_2d.screen_shake(8, 0.5)
		body.hit_enemy()
		body.play_hit_flash()
		frame_freeze(0.2, 0.3)
		
