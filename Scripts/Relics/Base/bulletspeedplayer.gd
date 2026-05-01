class_name BulletSpeedRelic
extends RelicBase

@export var speed_multiplier: float = 1.0

func modify_bullet_speed(base_speed, bullet, shooter):
	return base_speed * speed_multiplier
