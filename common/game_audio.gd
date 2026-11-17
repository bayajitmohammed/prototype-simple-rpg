class_name GameAudio
extends RefCounted

# One-shot effects live under the scene tree root so a scene change or
# a collected pickup cannot cut them off before they finish.
static func play(tree: SceneTree, stream: AudioStream, volume_db: float = 0.0) -> void:
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.name = "OneShotSound"
	player.stream = stream
	player.volume_db = volume_db
	tree.root.add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
