class_name Boss2
extends EnemyBase

@export_group("Movement")
@export var move_speed: float = 120.0
@export var randomness_strength: float = 0.4
@export var randomness_interval: float = 0.5

@export_group("Attack Timings")
@export var minigun_duration: float = 5.0
@export var shotgun_duration: float = 3.0
@export var sniper_cooldown: float = 2.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var minigun_pattern = $MinigunPattern
@onready var shotgun_pattern = $ShotgunPattern
@onready var sniper_pattern = $SniperPattern

var attack_cooldown := 0.0
var is_attacking := false
var is_dead_boss := false

var random_dir := Vector2.ZERO
var random_timer := 0.0

enum MoveMode {
	TOWARDS,
	AWAY
}

var move_mode = MoveMode.TOWARDS

func _ready():
	super._ready()
	if MusicManager:
		MusicManager.play_track("boss2")

func _process(delta):
	if player == null:
		return

	if current_health <= 0:
		return

	if is_dead_boss:
		return

	sprite.flip_h = player.global_position.x < global_position.x

	if attack_cooldown > 0:
		attack_cooldown -= delta

	if !is_attacking and attack_cooldown <= 0:
		choose_attack()

func _physics_process(delta):
	if player == null:
		return

	move_behavior(delta)

func choose_attack():
	match randi_range(0, 2):
		0:
			start_minigun()
		1:
			start_shotgun()
		2:
			start_sniper()
			
func move_behavior(delta):
	random_timer -= delta

	if random_timer <= 0:
		random_dir = Vector2(randf_range(-1,1),randf_range(-1,1)).normalized()
		random_timer = randomness_interval

	var desired_dir

	if move_mode == MoveMode.TOWARDS:
		desired_dir = (player.global_position - global_position).normalized()
	else:
		desired_dir = (global_position - player.global_position).normalized()

	var final_dir = (desired_dir + random_dir * randomness_strength).normalized()

	if is_on_wall():
		random_dir = get_wall_normal()

	velocity = final_dir * move_speed
	move_and_slide()

func start_minigun():
	is_attacking = true
	move_mode = MoveMode.TOWARDS

	await perform_minigun()

	is_attacking = false
	attack_cooldown = 1.5

func perform_minigun():
	var timer = minigun_duration
	while timer > 0:
		if player == null:
			break

		minigun_pattern.fire(self, player.global_position)
		await get_tree().create_timer(0.15).timeout
		timer -= 0.15

func start_shotgun():
	is_attacking = true
	move_mode = MoveMode.TOWARDS

	await perform_shotgun()

	is_attacking = false
	attack_cooldown = 1.5

func perform_shotgun():
	var timer = shotgun_duration
	while timer > 0:
		if player == null:
			break

		shotgun_pattern.fire(self,player.global_position)
		await get_tree().create_timer(0.6).timeout
		timer -= 0.6

func start_sniper():
	is_attacking = true
	move_mode = MoveMode.AWAY

	await perform_sniper()

	is_attacking = false
	attack_cooldown = sniper_cooldown

func perform_sniper():
	if player == null:
		return

	sniper_pattern.fire(self, player.global_position)

	await get_tree().create_timer(0.3).timeout
	
func die():
	is_dead_boss = true
	if MusicManager: MusicManager.play_track("gameplay")
	var tw = create_tween()
	tw.tween_property(sprite, "modulate", Color.BLACK, 0.5)
	tw.tween_callback(func(): super.die())
