class_name ProjectileSlowRelic
extends RelicBase

@export var slow_multiplier: float = 0.6  # 40% slower

func modify_incoming_bullet_speed(base_speed, bullet, player):
	return base_speed * slow_multiplier
