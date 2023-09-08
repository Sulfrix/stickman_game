extends Sprite2D

var velocity = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	var tw = create_tween()
	tw.tween_interval(0.5)
	tw.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.5)
	tw.tween_callback(self.queue_free)
	tw.play()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	velocity.y += 980*delta
	position += velocity*delta
