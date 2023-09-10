extends StaticBody2D

var health = 10.0
@onready var sprite: Sprite2D = $Sprite2D
var shard_scene = preload("res://objects/crate_shard.tscn")
var shake = 0.0
var time = 0.0

signal destroyed()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	#var bright = 0.5+0.5*((health/10.0))
	#modulate = Color(bright, bright, bright)
	sprite.position.x = sin(time*80)*shake
	sprite.position.y = sin(time*68+10.432)*shake
	shake = lerpf(shake, 0, 10*delta)
	

func _on_hurtbox_hit(hitinfo: HitInfo):
	health -= hitinfo.damage
	shake += hitinfo.damage
	if health <= 0:
		destroy(hitinfo.force)

func destroy(force: Vector2):
	emit_signal("destroyed")
	for i in range(20):
		var shard: Sprite2D = shard_scene.instantiate()
		get_parent().add_child(shard)
		shard.global_position = global_position
		shard.velocity = (force*randf_range(0.5, 1.3)).rotated(randf_range(-0.2, 0.2))
		shard.frame = i
	var sound = AudioStreamPlayer2D.new()
	sound.stream = preload("res://assets/sounds/crate_break.mp3")
	sound.pitch_scale = randf_range(0.9, 1.2)
	get_parent().add_child(sound)
	sound.global_position = global_position
	sound.play()
	sound.connect("finished", sound.queue_free)
	queue_free()
