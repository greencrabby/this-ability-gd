extends Node2D

@export var chest_scene: PackedScene

func spawn_chest(type):
	if chest_scene == null:
		print("No chest scene assigned!")
		return null

	var chest = chest_scene.instantiate()
	add_child.call(chest)

	chest.global_position = global_position
	chest.chest_type = type
	chest.setup(type)
	print("Spawned", chest.chest_type)

	return chest
