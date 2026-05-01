extends FirePatternBase

@export var bullet_scene: PackedScene
@export var bullet_texture: Texture2D
@export var bullet_speed: float = 200.0
@export var damage: float = 5.0
@export var spread_angle: float = 20.0
@export var pellet_count: int = 5

@onready var spawn_point: Marker2D = $"../BulletSpawn"

func fire(shooter, target_position):
	var base_dir = (target_position - spawn_point.global_position).normalized()
	
	for i in range(pellet_count):
		var angle_offset = deg_to_rad(randf_range(-spread_angle, spread_angle))
		var dir = base_dir.rotated(angle_offset)
		
		var bullet = bullet_scene.instantiate()
		get_tree().current_scene.add_child(bullet)
		
		bullet.global_position = spawn_point.global_position
		bullet.velocity = dir * bullet_speed
		bullet.rotation = dir.angle()
		
		bullet.damage = damage
		bullet.shooter = shooter
		bullet.faction = shooter.faction
		
		bullet.sprite.texture = bullet_texture
