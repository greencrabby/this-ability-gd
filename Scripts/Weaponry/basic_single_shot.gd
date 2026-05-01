extends WeaponBase

@export var bullet_scene: PackedScene
@export var bullet_texture: Texture2D
@export var bullet_speed: float = 200.0
@export var damage: float = 1.0
@export var spread_degrees: float = 3.0

@onready var spawn_point: Marker2D = $BulletSpawn
@onready var shoot_sound: AudioStreamPlayer2D = $ShootSound

func fire(shooter) -> bool:
	owner_ref = shooter
	if not super.fire(shooter):
		return false
	
	cooldown = 1.0 / get_fire_rate()
	shoot_sound.play()
	var final_damage = get_final_damage(damage)
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)

	bullet.global_position = spawn_point.global_position
	bullet.rotation = global_rotation

	var angle_offset = deg_to_rad(randf_range(-spread_degrees, spread_degrees))
	var direction = Vector2.RIGHT.rotated(global_rotation + angle_offset)

	bullet.base_speed = bullet_speed
	bullet.velocity = direction * bullet_speed
	bullet.shooter = shooter
	bullet.faction = shooter.faction
	bullet.damage = final_damage

	bullet.sprite.texture = bullet_texture
	
	return true
