extends FirePatternBase

@export var bullet_scene: PackedScene
@export var bullet_texture: Texture2D
@export var damage: float = 5.0
@export var bullet_speed: float = 150.0
@export var bullet_count: int = 12

@onready var spawn_point: Marker2D = $"../BulletSpawn"

func fire(shooter, target_position):
	for i in range(bullet_count):
		var angle = (TAU / bullet_count) * i
		var dir = Vector2.RIGHT.rotated(angle)
		
		var bullet = bullet_scene.instantiate()
		get_tree().current_scene.add_child(bullet)
		
		bullet.global_position = spawn_point.global_position
		bullet.velocity = dir * bullet_speed
		bullet.rotation = angle
		
		bullet.damage = damage
		bullet.shooter = shooter
		bullet.faction = shooter.faction
		
		bullet.sprite.texture = bullet_texture
