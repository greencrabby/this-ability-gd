extends Control

@onready var money_label = $MoneyLabel

func _process(delta):
	var manager = get_tree().get_first_node_in_group("map_manager")
	if manager:
		money_label.text = "Coins: %d" % manager.player_money
