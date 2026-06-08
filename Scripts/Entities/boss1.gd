class_name Boss1
extends EnemyBase

enum Phase { PHASE_1, PHASE_2 }
var phase: Phase = Phase.PHASE_1
@export var phase_2_threshold: float = 0.5
@export var phase_2_texture: Texture2D

@export_group("Normal Attack")
@export var normal_bullet_speed: float = 400.0
@export var normal_bullet_damage: float = 10.0

@export_group("Strong Attack / Phase 2")
@export var strong_bullet_speed: float = 600.0
@export var strong_bullet_damage: float = 20.0

var attack_cooldown: float = 0.0
var is_attacking: bool = false
var is_dead_boss: bool = false 

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var bullet_spawn: Marker2D = $BulletSpawn
@onready var pattern_single = $FirePattern1 
@onready var pattern_radial = $FirePattern2 

var random_dir: Vector2 = Vector2.ZERO
var random_timer: float = 0.0
@export var randomness_interval: float = 0.5
@export var randomness_strength: float = 0.3

func _ready():
	super._ready()
	if MusicManager:
		MusicManager.play_track("boss1")

func _process(delta):
	if current_health <= 0 or player == null or is_dead_boss:
		return

	var facing_left = player.global_position.x < global_position.x
	sprite.flip_h = facing_left
	
	if bullet_spawn.get_parent() == self:
		bullet_spawn.position.x = abs(bullet_spawn.position.x) * (-1 if facing_left else 1)

	handle_phase_transition()

	if is_attacking: return

	if attack_cooldown > 0:
		attack_cooldown -= delta
		move_towards_player()
		return

	handle_behavior()

func handle_phase_transition():
	var hp_percent = current_health / max_health
	if phase == Phase.PHASE_1 and hp_percent <= phase_2_threshold:
		phase = Phase.PHASE_2
		is_attacking = true
		play_anim("phasechange")

		await sprite.animation_finished
		is_attacking = false

func handle_behavior():
	var dist = global_position.distance_to(player.global_position)
	if phase == Phase.PHASE_1:
		if dist < 100: start_melee(false)
		else: start_shoot()
	elif phase == Phase.PHASE_2:
		if dist < 120:
			if randf() < 0.6: start_melee(true)
			else: start_slam()
		else: move_towards_player()

func move_towards_player():
	if player == null: return
	
	random_timer -= get_process_delta_time()
	if random_timer <= 0:
		random_dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		random_timer = randomness_interval

	var to_player = (player.global_position - global_position).normalized()

	var final_dir = (to_player + random_dir * randomness_strength).normalized()

	if is_on_wall():
		random_dir = get_wall_normal()
	
	velocity = final_dir * 100
	
	if phase == Phase.PHASE_1:
		play_anim("idlep1")
	else:
		play_anim("idlep2")
	move_and_slide()

func trigger_windup(anim_name:String, callback:Callable):
	is_attacking = true

	play_anim(anim_name)

	await sprite.animation_finished

	if current_health > 0:
		callback.call()

func start_melee(stronger := false):
	var windup = "slash_windupp1"
	var attack = "slashp1"

	if phase == Phase.PHASE_2:
		windup = "slash_windupp2"
		attack = "slashp2"

	trigger_windup(windup, func():
		play_anim(attack)
		perform_melee(stronger)
		await sprite.animation_finished
		end_attack(0.8)
	)

func start_shoot():
	trigger_windup("shoot_windupp1", func():
		play_anim("shootp1")
		perform_shoot()
		await sprite.animation_finished
		end_attack(1.0)
	)

func start_slam():
	trigger_windup("slam_windupp2", func():
		play_anim("slamp2")
		perform_slam()
		await sprite.animation_finished
		end_attack(1.5)
	)

func perform_melee(stronger: bool):
	var damage_val = 25 if stronger else 10
	if global_position.distance_to(player.global_position) < 130:
		if player.has_method("take_damage"):
			player.take_damage(damage_val, self)

func perform_shoot():
	if pattern_single:
		var s = strong_bullet_speed if phase == Phase.PHASE_2 else normal_bullet_speed
		var d = strong_bullet_damage if phase == Phase.PHASE_2 else normal_bullet_damage
		
		spawn_with_stats(pattern_single, s, d)

func perform_slam():
	if pattern_radial:
		spawn_with_stats(pattern_radial, strong_bullet_speed * 0.7, strong_bullet_damage)

func spawn_with_stats(pattern_node, speed, damage):
	if "custom_speed" in pattern_node: pattern_node.custom_speed = speed
	if "custom_damage" in pattern_node: pattern_node.custom_damage = damage
	pattern_node.fire(self, player.global_position)

func end_attack(cooldown_time):
	sprite.modulate = Color.WHITE
	is_attacking = false
	attack_cooldown = cooldown_time

	if phase == Phase.PHASE_1:
		play_anim("idlep1")
	else:
		play_anim("idlep2")

func die():
	is_dead_boss = true
	if MusicManager: MusicManager.play_track("gameplay")
	var tw = create_tween()
	tw.tween_property(sprite, "modulate", Color.BLACK, 0.5)
	tw.tween_callback(func(): super.die())
	
func play_anim(anim_name: String):
	if sprite.animation != anim_name:
		sprite.play(anim_name)
