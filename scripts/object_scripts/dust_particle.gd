extends Node2D

var lifetime = 1.0
var bouncy = 0.5
var despawning = false

var velocity = Vector2.ZERO

func _process(delta):
	velocity.y += 450 * delta
	
	translate(velocity * delta)
	
	lifetime -= delta;
	
	if lifetime <= 0 and not despawning:
		var tween = create_tween()
		tween.tween_property(self, "modulate", Color(255, 255, 255, 0), 0.06)
		tween.tween_callback(self.queue_free)
		despawning = true
		tween.play()
	
