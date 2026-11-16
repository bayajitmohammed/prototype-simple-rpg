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
		level.process_mode = Node.PROCESS_MODE_DISABLED
	
	for spawn_point in spawns_points_node.get_children():
		spawn_points[spawn_point.name] = spawn_point
		
	switch_level("Level0", "Bottom")
	

func switch_level(level_name: String, spawn_name: String):
	# Move the player to the spawn point BEFORE enabling the next level. All levels
	# share the same coordinates, so enabling first would let the next level's exit
	# triggers see the player still standing on the previous level's exit.
	var spawn: Marker2D = spawn_points[spawn_name]
	player.global_position = spawn.global_position

	if current_level:
		current_level.visible = false
		current_level.process_mode = Node.PROCESS_MODE_DISABLED
	
	var next_level: Node2D = levels[level_name]
	next_level.visible = true
	next_level.process_mode = Node.PROCESS_MODE_INHERIT
	current_level = next_level
	
	
