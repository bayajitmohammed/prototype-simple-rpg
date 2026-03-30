extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var levels_node: Node = $Levels
@onready var spawns_points_node: Node = $SpawnPoint

var levels: Dictionary = {}
var spawn_points: Dictionary = {}
var current_level: Node2D = null

func _ready() -> void:
	for level in levels_node.get_children():
		levels[level.name] = level
		level.visible = false
	
	for spawn_point in spawns_points_node.get_children():
		spawn_points[spawn_point.name] = spawn_point
		
	switch_level("Level0", "Bottom")
	

func switch_level(level_name: String, spawn_name: String):
	if current_level:
		current_level.visible = false
	
	var next_level: Node2D = levels[level_name]
	next_level.visible = true
	current_level = next_level
	
	var spawn: Marker2D = spawn_points[spawn_name]
	player.global_position = spawn.global_position
	
	
