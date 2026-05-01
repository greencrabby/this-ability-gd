extends Node2D

var selected_starter_pack

func _ready():
	var run = get_tree().get_first_node_in_group("run_manager")
	
	if run and selected_starter_pack:
		run.selected_starter_pack = selected_starter_pack
		run.start_run()
	$MapGenerator.generate()
	
