extends FirePatternBase

@export var bullet_scene: PackedScene
@export var bullet_texture: Texture2D
@export var bullet_speed: float = 200.0
@export var damage: float = 5.0

@onready var spawn_point: Marker2D = $"../BulletSpawn"

func fire(shooter, target_position):
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)

	bullet.global_position = spawn_point.global_position
	
	var direction = (target_position - spawn_point.global_position).normalized()
	
	bullet.velocity = direction * bullet_speed
	bullet.rotation = direction.angle()
	
	bullet.damage = damage
	bullet.shooter = shooter
	bullet.faction = shooter.faction
	
	bullet.sprite.texture = bullet_texture
