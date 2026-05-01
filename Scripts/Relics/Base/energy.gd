class_name EnergyRelic
extends RelicBase

@export var max_energy_bonus: float = 0
@export var regen_multiplier: float = 1.0

func modify_max_energy(value, player):
	return value + max_energy_bonus

func modify_energy_regen(value, player):
	return value * regen_multiplier
