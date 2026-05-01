class_name WeaponBase
extends Node2D

@export var display_texture: Texture2D

@export var energy_cost: float = 1.0
@export var fire_rate: float = 1.0

var cooldown: float = 0.0
var bonus_damage: float = 0.0
var bonus_energy_cost: float = 0.0
var bonus_fire_rate: float = 0.0

@export var has_alt_ability: bool = false
@export var alt_cooldown_time: float = 5.0

var alt_cooldown: float = 0.0

enum WeaponType {
	PISTOL,
	SMG,
	RIFLE,
	SHOTGUN,
	SNIPER,
	SWORD
}

@export var weapon_type: WeaponType
@export var rarity: Rarity.Type = Rarity.Type.COMMON

var owner_ref = null

func can_fire() -> bool:
	return cooldown <= 0

func fire(shooter) -> bool:
	if not can_fire():
		return false

	owner_ref = shooter
	cooldown = 1.0 / get_fire_rate()

	return true

func _process(delta):
	if cooldown > 0:
		cooldown -= delta
	
	if alt_cooldown > 0:
		alt_cooldown -= delta

func get_final_damage(base_damage: float) -> float:
	var dmg = base_damage + bonus_damage
	
	var run = get_tree().get_first_node_in_group("run_manager")
	if run:
		for relic in run.relics:
			dmg = relic.modify_damage(dmg, self, owner_ref)

	return dmg

func get_fire_rate() -> float:
	var rate = fire_rate + bonus_fire_rate
	
	var run = get_tree().get_first_node_in_group("run_manager")
	if run:
		for relic in run.relics:
			rate = relic.modify_fire_rate(rate, self, owner_ref)

	return rate

func get_energy_cost() -> float:
	var cost = energy_cost - bonus_energy_cost
	
	var run = get_tree().get_first_node_in_group("run_manager")
	if run:
		for relic in run.relics:
			cost = relic.modify_energy_cost(cost, self, owner_ref)

	return cost

func can_use_alt() -> bool:
	return has_alt_ability and alt_cooldown <= 0

func use_alt(shooter):
	pass
