extends EnemyBase

@export var fire_rate: float = 1.5
@export var bullet_speed: float = 200.0
@export var damage: float = 5.0

@onready var spawn_point: Marker2D = $BulletSpawn
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var cooldown: float = 0.0

@export var preferred_distance: float = 250.0
@export var move_speed: float = 100.0

@export var randomness_strength: float = 0.6
@export var randomness_interval: float = 0.6

var random_dir: Vector2 = Vector2.ZERO
var random_timer: float = 0.0

@onready var fire_pattern = $FirePattern

func _process(delta):
	if player == null:
		return

	if not can_see_player():
		return

	if player.global_position.x > global_position.x:
		sprite.flip_h = false 
	else:
		sprite.flip_h = true

	fire_pattern.try_fire(self, player.global_position)

func _physics_process(delta):
	if player == null:
		return

	if knockback_velocity.length() > 0:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_friction * delta)
		move_and_slide()
		return

	random_timer -= delta
	if random_timer <= 0:
		var random = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		
		var away_from_player = (global_position - player.global_position).normalized()
		
		random_dir = (random + away_from_player * 0.7).normalized()
		
		random_timer = randf_range(0.4, 1.0)

	if can_see_player():
		velocity = random_dir * move_speed
	else:
		velocity = random_dir * (move_speed * 0.6)

	move_and_slide()

	if is_on_wall():
		random_dir = -random_dir
