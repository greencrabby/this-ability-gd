class_name HealthRelic
extends RelicBase

@export var flat_bonus: float = 0
@export var percent_bonus: float = 0.0

func modify_max_health(value, player):
	return (value + flat_bonus) * (1.0 + percent_bonus)
