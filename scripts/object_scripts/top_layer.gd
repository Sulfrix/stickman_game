extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$PauseMenu.visible = false

func _input(event):
	if event.is_action_pressed("pause"):
		get_tree().paused = !get_tree().paused
		$PauseMenu.visible = get_tree().paused




func _on_exit_pressed():
	_on_unpaws_pressed()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _on_unpaws_pressed():
	get_tree().paused = false
	$PauseMenu.visible = false


func _on_hb_pressed():
	var tree := get_tree()
	tree.debug_collisions_hint = not tree.debug_collisions_hint

	# Traverse tree to call queue_redraw on instances of
	# CollisionShape2D and CollisionPolygon2D.
	var node_stack: Array[Node] = [tree.get_root()]
	while not node_stack.is_empty():
		var node: Node = node_stack.pop_back()
		if is_instance_valid(node):
			if node is CollisionShape2D or node is CollisionPolygon2D:
				node.queue_redraw()
			if node is TileMap:
				node.collision_visibility_mode = TileMap.VISIBILITY_MODE_FORCE_HIDE
				node.collision_visibility_mode = TileMap.VISIBILITY_MODE_DEFAULT
			node_stack.append_array(node.get_children())


func _on_time_scale_slider_value_changed(value):
	Engine.time_scale = value
	$PauseMenu/CenterContainer/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/Label.text = "time scale (" + str(value) + ")"
