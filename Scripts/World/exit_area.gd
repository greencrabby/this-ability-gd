extends Area2D

func _on_body_entered(body):
	if not body.is_in_group("player"):
		return
	
	print("Stage cleared!")

	var manager = get_tree().get_first_node_in_group("map_manager")
	if manager:
		manager.return_to_map()
