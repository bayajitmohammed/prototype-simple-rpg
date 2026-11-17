extends Node2D

const DUNGEON_AMBIENCE: AudioStreamOggVorbis = preload("res://sounds/ambience/dungeon_wind_drips.ogg")
const FIRE_AMBIENCE: AudioStreamWAV = preload("res://sounds/ambience/campfire_crackle.wav")
const FOREST_BIRDS: Array[AudioStream] = [
	preload("res://sounds/ambience/forest_bird_01.wav"),
	preload("res://sounds/ambience/forest_bird_02.wav"),
	preload("res://sounds/ambience/forest_bird_03.wav")
]

@onready var player: CharacterBody2D = $Player
@onready var levels_node: Node = $Levels
@onready var spawns_points_node: Node = $SpawnPoint
@onready var ambient_audio: AudioStreamPlayer = $AmbientAudio
@onready var fire_audio: AudioStreamPlayer = $FireAudio
@onready var bird_audio: AudioStreamPlayer = $BirdAudio

var levels: Dictionary = {}
var spawn_points: Dictionary = {}
var current_level: Node2D = null
var bird_delay: float = 0.0

func _ready() -> void:
	var dungeon_loop: AudioStreamOggVorbis = DUNGEON_AMBIENCE.duplicate()
	dungeon_loop.loop = true
	ambient_audio.stream = dungeon_loop
	ambient_audio.volume_db = -19.0

	var fire_loop: AudioStreamWAV = FIRE_AMBIENCE.duplicate()
	fire_loop.loop_mode = AudioStreamWAV.LOOP_FORWARD
	fire_audio.stream = fire_loop
	fire_audio.volume_db = -18.0
	bird_audio.volume_db = -15.0

	for level in levels_node.get_children():
		levels[level.name] = level
		level.visible = false
		level.process_mode = Node.PROCESS_MODE_DISABLED

	for spawn_point in spawns_points_node.get_children():
		spawn_points[spawn_point.name] = spawn_point

	switch_level("Level0", "Bottom", spawn_points["Bottom"].global_position)

func _process(delta: float) -> void:
	if current_level == null or not is_forest_level(current_level.name):
		return
	bird_delay -= delta
	if bird_delay <= 0.0:
		bird_audio.stream = FOREST_BIRDS.pick_random()
		bird_audio.play()
		bird_delay = randf_range(9.0, 17.0)

func is_forest_level(level_name: String) -> bool:
	return level_name in ["Level0", "Level1", "Level2", "Level3", "Level4"]

func switch_level(level_name: String, spawn_name: String, exit_position: Vector2) -> void:
	# Keep the position along the crossed edge and use the destination marker
	# only for the inward distance, clear of its entry trigger.
	var spawn: Marker2D = spawn_points[spawn_name]
	var entry_position: Vector2 = spawn.global_position
	if spawn_name == "Top" or spawn_name == "Bottom":
		entry_position.x = exit_position.x
	else:
		entry_position.y = exit_position.y
	# Move before enabling the next level so its triggers cannot see the
	# player standing on the previous level's exit.
	player.global_position = entry_position

	if current_level:
		current_level.visible = false
		current_level.process_mode = Node.PROCESS_MODE_DISABLED

	var next_level: Node2D = levels[level_name]
	next_level.visible = true
	next_level.process_mode = Node.PROCESS_MODE_INHERIT
	current_level = next_level

	var forest: bool = is_forest_level(level_name)
	var dungeon: bool = level_name in ["Level5", "Level6", "Level7", "Level8", "Level9"]
	if dungeon and not ambient_audio.playing:
		ambient_audio.play()
	elif not dungeon and ambient_audio.playing:
		ambient_audio.stop()

	if level_name == "Level8" and not fire_audio.playing:
		fire_audio.play()
	elif level_name != "Level8" and fire_audio.playing:
		fire_audio.stop()

	if forest and bird_delay <= 0.0:
		bird_delay = 2.0
	elif not forest:
		bird_audio.stop()
		bird_delay = 0.0
