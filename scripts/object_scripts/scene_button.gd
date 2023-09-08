extends Button

@export var go_to: PackedScene


func _pressed():
	if go_to:
		get_tree().change_scene_to_packed(go_to)

