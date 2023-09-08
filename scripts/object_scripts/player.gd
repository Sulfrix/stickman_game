extends CharacterBody2D


@export var SPEED = 400.0
@export var JUMP_VELOCITY = -580.0

var facing = 1

var wish_speed = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
@export var gravity = 980
@onready var anim = $AnimationPlayer
@onready var sprite = $Sprite

@onready var dust_scene = preload("res://objects/dust_particle.tscn")
@onready var hang_raycast = $Sprite/HangRaycast
@onready var extra_jump = $CollisionShape2D/ExtraJump
@onready var wall_detect = $Sprite/WallDetect

@export var can_attack = true

var hang_cooldown = 0

var state = "normal"

var jumped = false
var jump_canceled = false

var jump_buffer = 0.0

var noaccel = 0.0

var camera: Camera2D

var hang_object: Node2D
var hang_point: Vector2

var air_time = 0.0

func _ready():
	var testcam = get_node_or_null("Camera2D")
	#Engine.time_scale = 0.1
	if testcam:
		camera = testcam
		
func _process(delta):
	if jump_buffer > 0.0:
		jump_buffer -= delta
	else:
		jump_buffer = 0.0
		
	if Input.is_action_just_pressed("jump"):
		jump_buffer = 0.1
	
	if camera:
		camera.position = camera.position.lerp(velocity/5.5, 3*delta)

func turn_facing():
	facing = -facing

func _physics_process(delta):
	if hang_cooldown <= 0 and velocity.y > 0 and wall_detect.is_colliding() and hang_raycast.is_colliding() and state == "normal":
		if hang_raycast.get_collision_normal().dot(Vector2.UP) > 0.8:
			state = "hang"
			hang_cooldown = 0.3
			global_position.x = wall_detect.get_collision_point(0).x - (facing*32.0/2.0)
			global_position.y = hang_raycast.get_collision_point().y + 121.0/2.0
			hang_object = hang_raycast.get_collider()
			hang_point = hang_object.global_transform.inverse() * hang_raycast.get_collision_point()
	
	if hang_cooldown > 0:
		if state != "hang":
			hang_cooldown -= delta
	else:
		hang_cooldown = 0
		
	noaccel = move_toward(noaccel, 0.0, delta*2.3)
	
	var move_input = Input.get_axis("move_left", "move_right")
	var move_analog = Input.get_axis("move_left_analog", "move_right_analog")
	if abs(move_analog) > abs(move_input):
		move_input = move_analog
	wish_speed = SPEED*move_input
	
	match state:
		"normal":
			base_physics(delta)
		"hang":
			hang_logic(delta)
		"attack":
			attack_logic(delta)
	

func attack_logic(delta):
	sprite.scale.x = facing
	var gravmult = 1
	if velocity.y > 0:
		gravmult += 1
	velocity.y += gravity * delta * gravmult
	
	if is_on_floor():
		velocity.x = lerpf(velocity.x, 0, 3*delta)
	
	if !anim.is_playing():
		anim.play("RESET")
		state = "normal"
	
	move_and_slide()

func base_physics(delta):
	# Add the gravity.
	if not is_on_floor():
		var gravmult = 1
		if jump_canceled or velocity.y > 0:
			gravmult *= 2
		velocity.y += gravity * delta * gravmult
	
	#var move_input = Input.get_axis("move_left", "move_right")
	
	
	var move_mult = 1.0
	
	if sign(wish_speed) == 1:
		facing = 1
	if sign(wish_speed) == -1:
		facing = -1
		
	if Input.is_action_pressed("walk"):
		move_mult *= 0.9
	
	if sign(velocity.x) == sign(wish_speed) and is_on_floor() and abs(wish_speed) > abs(velocity.x) and not wall_detect.is_colliding() and !Input.is_action_pressed("walk"):
		if abs(wish_speed - velocity.x) > 200:
			dust_particles(-facing, randi_range(15, 20), 1.1)
		velocity.x = wish_speed*move_mult
		
	else:
		if !is_on_floor():
			move_mult *= 1
		velocity.x = lerpf(velocity.x, wish_speed*move_mult, 3*delta*(1-noaccel))
	
	if is_on_floor():
		air_time = 0.0
		velocity.y = 0
		jumped = false
		jump_canceled = false
		if jump_buffer > 0.0:
			jump()
	else:
		air_time += delta
		if extra_jump.is_colliding():
			if jump_buffer > 0.0 and extra_jump.get_collision_normal(0) == Vector2.UP and velocity.y > 0:
				global_position.y = extra_jump.get_collision_point(0).y - 121.0/2.0
				jump()
			
	if !is_on_floor():
		if jump_buffer > 0.0 and air_time < 0.2 and !jumped:
			jump()
		if jumped:
			if !jump_canceled and !Input.is_action_pressed("jump") and velocity.y < 0:
				velocity.y /= 1.5
				jump_canceled = true
		# Wall jumping. Disabled.
		if false and jump_buffer > 0.0 and wall_detect.is_colliding():
			velocity.x -= facing * 500
			facing *= -1
			noaccel = 1.0
			jump(0.7)
			
	
	
	move_and_slide()
	if can_attack and Input.is_action_just_pressed("attack"):
		if is_on_floor() or velocity.y > 0:
			attack("bat")
		else:
			attack("bat_air")
	else:
		anim_logic(delta)
		sprite.scale.x = facing

func jump(mult=1.0):
	velocity.y = JUMP_VELOCITY*mult
	jumped = true
	jump_canceled = false
	jump_buffer = 0.0

func attack(anim_name):
	anim.speed_scale = 1
	anim.play("RESET")
	anim.play(anim_name)
	state = "attack"

func dust_particles(dir, amount, velmult=1.0):
	for i in range(amount):
		var partvel = Vector2(dir*randf_range(120, 160), randf_range(-80, -180))
		var part: Node2D = dust_scene.instantiate()
		get_parent().add_child(part)
		part.lifetime = randf_range(0.6, 0.2)
		part.global_position = global_position + Vector2(dir * 18, 55) + Vector2(randf_range(-5, 5), randf_range(-5, 5))
		part.velocity = partvel*velmult+velocity/4
		part.bouncy = Vector2(0.4, 0.6)

func facing_dust_particles(amount: int):
	dust_particles(facing*1.4, amount, 0.6)

func hang_logic(_delta):
	play_anim("hang", 1)
	velocity = Vector2.ZERO
	if !hang_raycast.is_colliding() or !wall_detect.is_colliding():
		state = "normal"
		return
	var point = hang_object.global_transform * hang_point
	global_position.x = point.x - (facing*32.0/2.0)
	wall_detect.force_shapecast_update()
	global_position.x = wall_detect.get_collision_point(0).x - (facing*32.0/2.0)
	global_position.y = point.y + 121.0/2.0
	move_and_collide(Vector2.ZERO)
	if jump_buffer > 0.0:
		if Input.is_action_pressed("down") or Input.is_action_pressed("down_analog"):
			state = "normal"
			jump_buffer = 0.0
		else:
			jump(1.0)
			velocity.x = wish_speed
			state = "normal"

func anim_logic(_delta):
	if is_on_floor():
		if abs(wish_speed) > 0 and abs(velocity.x) > 0:
			if sign(velocity.x) != sign(wish_speed):
				facing = -sign(wish_speed)
				play_anim("skid", 1)
			else:
				play_anim("run", abs(velocity.x)/(500.0*0.48))
		else:
			if abs(velocity.x) > 60:
				#facing = -sign(velocity.x)
				play_anim("skid", 1)
			else:
				play_anim("idle", 1)
	else:
		if velocity.y > 0:
			play_anim("fall", 1)
		else:
			play_anim("jump", 1)

func play_anim(anim_name, speed):
	if anim.current_animation != anim_name:
		anim.play(anim_name)
	anim.speed_scale = speed
