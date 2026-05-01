class_name WeaponRelic
extends RelicBase

@export var damage_multiplier: float = 1.0
@export var fire_rate_multiplier: float = 1.0
@export var energy_cost_multiplier: float = 1.0

func modify_damage(value, weapon, player):
	return value * damage_multiplier

func modify_fire_rate(value, weapon, player):
	return value * fire_rate_multiplier

func modify_energy_cost(value, weapon, player):
	return value * energy_cost_multiplier
