class_name MoneyRelic
extends RelicBase

@export var multiplier: float = 1.0

func modify_currency_gain(amount, player):
	return int(amount * multiplier)
