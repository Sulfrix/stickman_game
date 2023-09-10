class_name HitInfo
extends RefCounted

var damage: float = 0.0
var force: Vector2 = Vector2.ZERO
var stunning: bool = false

var damage_type: Enums.DamageType = Enums.DamageType.BASIC

var team: Enums.Team = Enums.Team.PLAYER

var hitbox: Hitbox
var attacker: Node2D

var victim_hurtbox: Hurtbox
var victim: Node2D

func _init():
	pass
	
func copy() -> HitInfo:
	var out = HitInfo.new()
	out.damage = damage
	out.force = force
	out.stunning = stunning
	
	out.damage_type = damage_type
	
	out.team = team
	
	out.hitbox = hitbox
	out.attacker = attacker
	
	out.victim_hurtbox = victim_hurtbox
	out.victim = victim
	return out
	
func copy_with_damage(new_damage: float) -> HitInfo:
	var out = self.copy()
	out.damage = new_damage
	return out
