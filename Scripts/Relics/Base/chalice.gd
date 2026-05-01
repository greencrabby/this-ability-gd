class_name MoneyDamageRelic
extends RelicBase

@export var scaling_damage: float = 0.001  # per money
@export var scaling_firerate: float = 0.001

func modify_damage(value, weapon, player):
	var run = player.get_tree().get_first_node_in_group("run_manager")
	if run:
		return value * (1.0 + run.money * scaling_damage)
	return value

func modify_fire_rate(value, weapon, player):
	var run = player.get_tree().get_first_node_in_group("run_manager")
	if run:
		return value * (1.0 + run.money * scaling_firerate)
	return value
