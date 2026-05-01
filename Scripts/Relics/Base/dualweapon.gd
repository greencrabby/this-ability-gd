class_name DualWeaponRelic
extends RelicBase

@export var buffed_types: Array[WeaponBase.WeaponType]
@export var nerfed_types: Array[WeaponBase.WeaponType]

@export var buff_damage_mult: float = 1.0
@export var nerf_damage_mult: float = 1.0

@export var buff_fire_rate_mult: float = 1.0
@export var nerf_fire_rate_mult: float = 1.0

@export var buff_energy_cost_mult: float = 1.0
@export var nerf_energy_cost_mult: float = 1.0

func modify_damage(value, weapon, player):
	if weapon.weapon_type in buffed_types:
		return value * buff_damage_mult
	
	if weapon.weapon_type in nerfed_types:
		return value * nerf_damage_mult
	
	return value

func modify_fire_rate(value, weapon, player):
	if weapon.weapon_type in buffed_types:
		return value * buff_fire_rate_mult
	
	if weapon.weapon_type in nerfed_types:
		return value * nerf_fire_rate_mult
	
	return value

func modify_energy_cost(value, weapon, player):
	if weapon.weapon_type in buffed_types:
		return value * buff_energy_cost_mult
	
	if weapon.weapon_type in nerfed_types:
		return value * nerf_energy_cost_mult
	
	return value
