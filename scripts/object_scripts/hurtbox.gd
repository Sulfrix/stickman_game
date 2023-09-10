class_name Hurtbox
extends Area2D

@export var team: Enums.Team

signal hit(hitinfo: HitInfo)

func _ready():
	if get_parent():
		if "team" in get_parent():
			team = get_parent().team
