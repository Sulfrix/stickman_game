@tool
class_name Hitbox
extends Area2D



@export_group("Stats")
@export var damage = 10.0
@export_subgroup("Knockback", "knockback_")
@export var knockback_direction: Vector2 = Vector2.RIGHT:
	get:
		return knockback_direction
	set(value):
		knockback_direction = value.normalized()
@export var knockback_force = 0.0
@export var team: Enums.Team = Enums.Team.NEUTRAL
@export var stunning: bool = false

@onready var hit_objects: Array[Node2D] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("area_entered", area_entered)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	monitorable = visible
	monitoring = visible
	if Engine.is_editor_hint() and visible:
		queue_redraw()
	
	if hit_objects.size() > 0:
		hit_objects = []

func _draw():
	if Engine.is_editor_hint():
		draw_line(Vector2.ZERO, knockback_direction*knockback_force, Color.WEB_GRAY, 4.0)

func area_entered(body: Area2D):
	if body is Hurtbox and !hit_objects.has(body.owner):
		var hb = body as Hurtbox
		if hb.owner == owner:
			return
		if hb.team == team:
			return
		var hitinfo = HitInfo.new()
		hitinfo.damage = damage
		hitinfo.force = global_transform.basis_xform(knockback_direction*knockback_force)
		hitinfo.team = team
		hitinfo.stunning = stunning
		
		hitinfo.attacker = owner
		hitinfo.hitbox = self
		
		hitinfo.victim = body.owner
		hitinfo.victim_hurtbox = body
		
		hb.emit_signal("hit", hitinfo)
		hit_objects.append(hb.owner)


