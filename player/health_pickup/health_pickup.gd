extends Area2D

# body_entered is connected in health_pickup.tscn (Node > Signals), so no connect() here.
func _on_body_entered(body):
	if body.name == "Player" and body.has_method("heal_to_full") and  body.health < body.max_health:
		body.heal_to_full()
		queue_free()
