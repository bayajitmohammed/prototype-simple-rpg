extends Node2D
## Controls hint shown at the start of level 0. Fades out once the player starts moving.

@export var fade_time: float = 0.4

var _player: CharacterBody2D
var _fading: bool = false


func _ready() -> void:
	_player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if DisplayServer.is_touchscreen_available():
		$Panel/Label.text = "Drag left pad - Move\nTap ATTACK - Attack\nHead north to begin!"


func _process(_delta: float) -> void:
	if _fading or _player == null:
		return
	if _player.velocity.length() > 0.0:
		_fading = true
		var tween: Tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, fade_time)
		tween.tween_callback(queue_free)
