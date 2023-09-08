class_name HitInfo
extends RefCounted

var damage: float = 0.0
var knockback_direction: Vector2 = Vector2.UP
var knockback_force: float = 0.0

enum DamageType {BASIC, FIRE}
var damage_type: DamageType = DamageType.BASIC

enum DamageTeam {PLAYER, ENEMY}
var team: DamageTeam = DamageTeam.PLAYER

var hitbox: Hitbox
var attacker: Node2D

var victim_hurtbox: Hurtbox
var victim: Node2D

func _init():
	pass
	
func copy() -> HitInfo:
	var out = HitInfo.new()
	out.damage = damage
	out.knockback_direction = knockback_direction
	out.knockback_force = knockback_force
	
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
