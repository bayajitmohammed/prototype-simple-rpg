extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player" and body.has_method("heal_to_full") and  body.health < body.max_health:
		body.heal_to_full()
		queue_free()
