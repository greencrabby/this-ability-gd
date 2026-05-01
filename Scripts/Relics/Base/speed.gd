class_name MovementRelic
extends RelicBase

@export var accel_multiplier: float = 1.0
@export var speed_multiplier: float = 1.0

func modify_acceleration(value, player):
	return value * accel_multiplier

func modify_max_speed(value, player):
	return value * speed_multiplier
