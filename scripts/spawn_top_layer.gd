extends Node

func _ready():
	var scene: PackedScene = preload("res://scenes/top_layer.tscn")
	var top_layer = scene.instantiate()
	var canvas_layer = CanvasLayer.new()
	canvas_layer.add_child(top_layer)
	get_tree().root.add_child.call_deferred(canvas_layer)
	queue_free()
