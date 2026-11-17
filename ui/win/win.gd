extends Control

const BUTTON_SOUND: AudioStream = preload("res://sounds/effects/menu_click.ogg")


func _on_button_pressed() -> void:
	GameAudio.play(get_tree(), BUTTON_SOUND, -10.0)
	get_tree().change_scene_to_file("res://ui/welcome/welcome.tscn")
