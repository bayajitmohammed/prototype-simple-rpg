extends Node2D

@export var next_level_top := ""
@export var next_level_bottom := ""
@export var next_level_left := ""
@export var next_level_right := ""

@onready var triggers: Node2D = $Triggers
@onready var world: Node2D = get_tree().get_root().get_node("World")

var exit_points := {}

func _ready() -> void:
	exit_points = {
		"Top": {"trigger": triggers.get_node("Top"), "level": next_level_top, "spawn": "Bottom"},
		"Bottom": {"trigger": triggers.get_node("Bottom"), "level": next_level_bottom, "spawn": "Top"},
		"Left": {"trigger": triggers.get_node("Left"), "level": next_level_left, "spawn": "Right"},
		"Right": {"trigger": triggers.get_node("Right"), "level": next_level_right, "spawn": "Left"},
	}
	# visibility_changed fires even while the level is PROCESS_MODE_DISABLED,
	# unlike _process, so the triggers can never be left on in a hidden level.
	get_parent().visibility_changed.connect(_on_level_visibility_changed)
	_on_level_visibility_changed()


func _on_level_visibility_changed() -> void:
	if not get_parent().visible:
		_set_monitoring(false)
		return
	# Turn the exits on only after a physics frame, once the player has been
	# placed along the entry edge. Otherwise a trigger can report the player's
	# overlap from the previous level's exit (all levels share coordinates).
	await get_tree().physics_frame
	_set_monitoring(get_parent().visible)


func _set_monitoring(enabled: bool) -> void:
	for exit_point in exit_points.keys():
		var trigger_info = exit_points[exit_point]
		var trigger: Area2D = trigger_info["trigger"]
		var level_name: String = trigger_info["level"]
		if trigger:
			trigger.monitoring = enabled and level_name != ""
			
func _handle_player_entered(body: Node2D, exit_point: String) -> void:
	if body.name != "Player":
		return
	# Only the level the player is actually in may send them somewhere.
	if world.current_level != get_parent():
		return
	var trigger_info = exit_points[exit_point]
	var target_level: String = trigger_info["level"]
	var target_spawn: String = trigger_info["spawn"]
	
	if target_level != "":
		# Deferred: switching disables this level's physics bodies, which Godot
		# does not allow from inside a physics callback such as body_entered.
		world.switch_level.call_deferred(target_level, target_spawn, body.global_position)


func _on_top_body_entered(body: Node2D) -> void:
	_handle_player_entered(body, "Top")


func _on_bottom_body_entered(body: Node2D) -> void:
	_handle_player_entered(body, "Bottom")


func _on_left_body_entered(body: Node2D) -> void:
	_handle_player_entered(body, "Left")


func _on_right_body_entered(body: Node2D) -> void:
	_handle_player_entered(body, "Right")
