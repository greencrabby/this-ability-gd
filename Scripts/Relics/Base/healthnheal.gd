class_name HealRelic
extends RelicBase

@export var heal_amount: float = 0
@export var max_hp_bonus: float = 0

func modify_max_health(value, player):
	return value + max_hp_bonus

func on_pickup(player):
	var run = player.get_tree().get_first_node_in_group("run_manager")
	if run:
		run.heal(heal_amount)
