class_name Boss1
extends EnemyBase

# =========================
# 🎯 PHASE SYSTEM
# =========================
enum Phase { PHASE_1, PHASE_2 }
var phase: Phase = Phase.PHASE_1
@export var phase_2_threshold: float = 0.5
@export var phase_2_texture: Texture2D

# =========================
# 📊 BOSS BALANCING (Inspector)
# =========================
@export_group("Normal Attack")
@export var normal_bullet_speed: float = 400.0
@export var normal_bullet_damage: float = 10.0

@export_group("Strong Attack / Phase 2")
@export var strong_bullet_speed: float = 600.0
@export var strong_bullet_damage: float = 20.0

# =========================
# 🎮 STATE
# =========================
var attack_cooldown: float = 0.0
var is_attacking: bool = false
var is_dead_boss: bool = false 

# =========================
# 🎨 NODES
# =========================
@onready var sprite: Sprite2D = $Sprite2D 
@onready var bullet_spawn: Marker2D = $BulletSpawn
@onready var pattern_single = $FirePattern1 
@onready var pattern_radial = $FirePattern2 

# Randomness
var random_dir: Vector2 = Vector2.ZERO
var random_timer: float = 0.0
@export var randomness_interval: float = 0.5
@export var randomness_strength: float = 0.3

# =========================
# 🚀 INIT
# =========================
func _ready():
	super._ready()
	if MusicManager:
		MusicManager.play_track("boss")

# =========================
# 🔄 PROCESS
# =========================
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

# =========================
# 🔄 PHASE TRANSITION
# =========================
func handle_phase_transition():
	var hp_percent = current_health / max_health
	if phase == Phase.PHASE_1 and hp_percent <= phase_2_threshold:
		phase = Phase.PHASE_2
		trigger_windup("Entering Phase 2!", 1.5, func():
			if phase_2_texture:
				sprite.texture = phase_2_texture
			
			sprite.self_modulate = Color(1.5, 0.5, 0.5) 
			var tw = create_tween()
			tw.tween_property(sprite, "scale", Vector2(1.5, 1.5), 0.1)
			tw.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.2)
			
			end_attack(1.0)
		)

# =========================
# 🧠 BEHAVIOR
# =========================
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
	
	# 1. Update Randomness Timer
	random_timer -= get_process_delta_time()
	if random_timer <= 0:
		random_dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		random_timer = randomness_interval

	# 2. Calculate Direction (Like the Melee Enemy)
	var to_player = (player.global_position - global_position).normalized()
	
	# Mix direct path with randomness to prevent sticking on corners
	var final_dir = (to_player + random_dir * randomness_strength).normalized()
	
	# 3. Wall Avoidance
	if is_on_wall():
		random_dir = get_wall_normal() # Bounce off the wall
	
	velocity = final_dir * 100
	move_and_slide()

# =========================
# ⚔️ ATTACK STARTERS
# =========================
func trigger_windup(attack_name: String, duration: float, callback: Callable):
	is_attacking = true
	sprite.modulate = Color.RED 
	await get_tree().create_timer(duration).timeout
	if current_health > 0: callback.call()

func start_melee(stronger := false):
	trigger_windup("Melee", 0.6, func():
		perform_melee(stronger)
		end_attack(0.8)
	)

func start_shoot():
	trigger_windup("Shoot", 0.8, func():
		perform_shoot()
		end_attack(1.0)
	)

func start_slam():
	trigger_windup("Slam", 1.0, func():
		perform_slam()
		end_attack(1.5)
	)

# =========================
# 💥 PERFORM ATTACKS (With Stat Overrides)
# =========================
func perform_melee(stronger: bool):
	var damage_val = 25 if stronger else 10
	if global_position.distance_to(player.global_position) < 130:
		# 🟢 Call the player's damage function, not the RunManager directly
		if player.has_method("take_damage"):
			player.take_damage(damage_val, self)

func perform_shoot():
	if pattern_single:
		# Use strong stats if in Phase 2
		var s = strong_bullet_speed if phase == Phase.PHASE_2 else normal_bullet_speed
		var d = strong_bullet_damage if phase == Phase.PHASE_2 else normal_bullet_damage
		
		# We pass these to a helper function that tells the pattern what to do
		spawn_with_stats(pattern_single, s, d)

func perform_slam():
	if pattern_radial:
		# Slams are always "Strong" stats
		spawn_with_stats(pattern_radial, strong_bullet_speed * 0.7, strong_bullet_damage)

# Helper to "Inject" stats into the pattern instance
func spawn_with_stats(pattern_node, speed, damage):
	# We temporarily change the pattern's exports before it fires
	if "custom_speed" in pattern_node: pattern_node.custom_speed = speed
	if "custom_damage" in pattern_node: pattern_node.custom_damage = damage
	pattern_node.fire(self, player.global_position)

func end_attack(cooldown_time):
	sprite.modulate = Color.WHITE 
	is_attacking = false
	attack_cooldown = cooldown_time

# =========================
# 💀 DIE
# =========================
func die():
	is_dead_boss = true
	if MusicManager: MusicManager.play_track("gameplay")
	var tw = create_tween()
	tw.tween_property(sprite, "modulate", Color.BLACK, 0.5)
	tw.tween_callback(func(): super.die())
	
