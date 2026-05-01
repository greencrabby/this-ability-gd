class_name WeaponTypeRelic
extends RelicBase

@export var weapon_types: Array[WeaponBase.WeaponType]
@export var damage_multiplier: float = 1.0
@export var fire_rate_multiplier: float = 1.0
@export var energy_cost_multiplier: float = 1.0

func modify_damage(value, weapon, player):
	if weapon.weapon_type in weapon_types:
		return value * damage_multiplier
	return value

func modify_fire_rate(value, weapon, player):
	if weapon.weapon_type in weapon_types:
		return value * fire_rate_multiplier
	return value

func modify_energy_cost(value, weapon, player):
	if weapon.weapon_type in weapon_types:
		return value * energy_cost_multiplier
	return value
