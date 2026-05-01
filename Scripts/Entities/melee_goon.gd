extends EnemyBase

@export var speed: float = 120.0
@export var contact_damage: float = 10.0

@export var randomness_strength: float = 0.4
@export var randomness_interval: float = 0.5

var random_dir: Vector2 = Vector2.ZERO
var random_timer: float = 0.0

@export var retreat_time: float = 1.0
@export var retreat_speed: float = 200.0

var retreat_timer: float = 0.0
var retreat_direction: Vector2 = Vector2.ZERO

@onready var hitbox: Area2D = $Hitbox

func _physics_process(delta):
	if player == null:
		return

	if knockback_velocity.length() > 0:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_friction * delta)
		move_and_slide()
		return

	if retreat_timer > 0:
		retreat_timer -= delta
		velocity = retreat_direction * retreat_speed
		move_and_slide()
		return

	random_timer -= delta
	if random_timer <= 0:
		random_dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		random_timer = randomness_interval

	if can_see_player():
		var to_player = (player.global_position - global_position).normalized()
		var final_dir = (to_player + random_dir * randomness_strength).normalized()
		
		velocity = final_dir * speed
	else:
		velocity = random_dir * (speed * 0.6)

	if is_on_wall():
		random_dir = -random_dir
		
	move_and_slide()

func _on_hit(body):
	if not body.is_in_group("player"):
		return
	
	body.take_damage(contact_damage, self)
	
	# trigger retreat
	retreat_timer = retreat_time
	retreat_direction = (global_position - body.global_position).normalized()
