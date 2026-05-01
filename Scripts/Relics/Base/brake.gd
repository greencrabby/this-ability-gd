class_name BrakeRelic
extends RelicBase

@export var brake_multiplier: float = 1.0

func modify_brake_force(value, player):
	return value * brake_multiplier
