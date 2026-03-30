extends Node2D

@export var next_level_top := ""
@export var next_level_bottom := ""
@export var next_level_left := ""
@export var next_level_right := ""

@onready var triggers: Node2D = $Triggers
@onready var world: Node2D = get_tree().get_root().get_node("World")

var parent_visibility := false
var exit_points := {}

func _ready() -> void:
	exit_points = {
		"Top": {"trigger": triggers.get_node("Top"), "level": next_level_top, "spawn": "Bottom"},
		"Bottom": {"trigger": triggers.get_node("Bottom"), "level": next_level_bottom, "spawn": "Top"},
		"Left": {"trigger": triggers.get_node("Left"), "level": next_level_left, "spawn": "Right"},
		"Right": {"trigger": triggers.get_node("Right"), "level": next_level_right, "spawn": "Left"},
	}
	
	_update_area2d_monitoring()
	

func _process(_delta: float) -> void:
	var is_parent_visible = get_parent().visible
	if parent_visibility != is_parent_visible:
		parent_visibility = is_parent_visible
		_update_area2d_monitoring()
			
func _update_area2d_monitoring():
	for exit_point in exit_points.keys():
		var trigger_info = exit_points[exit_point]
		var trigger: Area2D = trigger_info["trigger"]
		var level_name: String = trigger_info["level"]
		if trigger:
			trigger.monitoring = (level_name != "") and parent_visibility
			
func _handle_player_entered(body: Node2D, exit_point: String) -> void:
	if body.name != "Player":
		return
	var trigger_info = exit_points[exit_point]
	var target_level: String = trigger_info["level"]
	var target_spawn: String = trigger_info["spawn"]
	
	if target_level != "":
		world.switch_level(target_level, target_spawn)


func _on_top_body_entered(body: Node2D) -> void:
	_handle_player_entered(body, "Top")


func _on_bottom_body_entered(body: Node2D) -> void:
	_handle_player_entered(body, "Bottom")


func _on_left_body_entered(body: Node2D) -> void:
	_handle_player_entered(body, "Left")


func _on_right_body_entered(body: Node2D) -> void:
	_handle_player_entered(body, "Right")
