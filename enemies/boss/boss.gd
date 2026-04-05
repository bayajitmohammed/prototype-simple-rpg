extends StaticBody2D

@export var fireball_scene: PackedScene
@onready var marker: Marker2D = $Marker2D
var player: CharacterBody2D

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	

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
