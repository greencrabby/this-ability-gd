extends WeaponBase

@export var damage: float = 3.0
@export var attack_duration: float = 0.1

@onready var hitbox: Area2D = $Hitbox
@onready var swing_sound: AudioStreamPlayer2D = $SwingSound
@onready var deflect_sound: AudioStreamPlayer2D = $DeflectSound

@onready var idle_sprite: Sprite2D = $Sprite2D
@onready var slash_sprite: Sprite2D = $SlashSprite
@export var idle_texture: Texture2D
@export var slash_texture: Texture2D
@export var damage_number_scene: PackedScene

var swing_up: bool = true
var hit_targets: Array = []

var is_attacking: bool = false

func _ready():
	idle_sprite.visible = true
	slash_sprite.visible = false
	hitbox.monitoring = false
	
func _process(delta):
	super(delta)

func fire(shooter) -> bool:
	if not super.fire(shooter):
		return false
	
	owner_ref = shooter
	cooldown = 1.0 / get_fire_rate()
	start_attack()
	
	return true

func start_attack():
	swing_sound.play()
	hit_targets.clear()
	is_attacking = true

	idle_sprite.visible = false
	slash_sprite.visible = true

	slash_sprite.texture = slash_texture
	slash_sprite.flip_v = swing_up
	swing_up = !swing_up

	var base_rot = slash_sprite.rotation
	slash_sprite.rotation += deg_to_rad(10 if swing_up else -10)

	await get_tree().create_timer(0.05).timeout
	slash_sprite.rotation = base_rot

	# activate hit window
	await get_tree().create_timer(0.04).timeout
	hitbox.monitoring = true

	await get_tree().create_timer(0.06).timeout
	hitbox.monitoring = false

	is_attacking = false

	slash_sprite.visible = false
	idle_sprite.visible = true

func _on_hit(body):
	if not is_attacking:
		return
		
	if body == owner_ref:
		return
		
	if "faction" in body and "faction" in owner_ref:
		if body.faction == owner_ref.faction:
			return

	if body in hit_targets:
		return
	
	hit_targets.append(body)

	if body.has_method("deflect_bullet"):
		swing_sound.stop()
		deflect_sound.play()
		
		var dir = Vector2.RIGHT.rotated(global_rotation)
		body.deflect_bullet(dir)
		return

	if body.has_method("take_damage"):
		var final_damage = get_final_damage(damage)
		spawn_damage_number(body.global_position, damage)
		body.take_damage(final_damage, owner_ref)
		
		if body.has_method("apply_knockback"):
			var dir = (body.global_position - global_position).normalized()
			body.apply_knockback(dir * 300)

func spawn_damage_number(pos: Vector2, amount: float):
	if damage_number_scene == null:
		return
	
	var dmg = damage_number_scene.instantiate()
	get_tree().current_scene.add_child(dmg)
	
	dmg.global_position = pos
	dmg.setup(amount)
