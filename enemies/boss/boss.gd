extends StaticBody2D

@export var max_health: int = 100
@export var fireball_scene: PackedScene
@onready var marker: Marker2D = $Marker2D
@onready var sprite: Sprite2D = $Boss
@onready var health_bar: ProgressBar = $HealthBar
var player: CharacterBody2D
var health: int = 100

func _ready() -> void:
	health = max_health
	health_bar.max_value = max_health
	health_bar.value = health
	player = get_tree().get_first_node_in_group("player")

func hit_enemy():
	if health <= 0:
		return
	health -= 5
	health = max(health, 0)
	update_health_bar()
	if health <= 0:
		# Deferred so the attacker's hit code (flash, frame freeze) finishes
		# before this scene is removed from the tree.
		get_tree().change_scene_to_file.call_deferred("res://ui/win/win.tscn")
		
func play_hit_flash():
	var mat = sprite.material
	if not mat:
		return
	
	var tween = create_tween()
	tween.tween_property(mat, "shader_parameter/flash_value", 1.0, 0.05)
	tween.tween_property(mat, "shader_parameter/flash_value", 0.0, 0.1)
	
func update_health_bar():
	var tween = create_tween()
	tween.tween_property(health_bar, "value", health, 0.2)


func shoot():
	if player == null or fireball_scene == null:
		return
	var fireball = fireball_scene.instantiate()
	fireball.global_position = marker.global_position
	
	var direction = (player.global_position - marker.global_position).normalized()
	fireball.direction = direction
	fireball.look_at(player.global_position)
	fireball.rotation += deg_to_rad(-90)
	
	get_tree().current_scene.add_child(fireball)


func _on_timer_timeout() -> void:
	shoot()
