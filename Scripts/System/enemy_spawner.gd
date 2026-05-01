extends Node2D

@export var enemy_pool: Array[PackedScene]
@export var spawn_points: Array[Node2D]
@export var min_enemies: int = 3
@export var max_enemies: int = 6

func spawn_enemies() -> Array:
	var spawned = []

	var count = randi_range(min_enemies, max_enemies)

	for i in range(count):
		if enemy_pool.is_empty():
			break

		var enemy_scene = enemy_pool.pick_random()
		var enemy = enemy_scene.instantiate()

		var point = spawn_points.pick_random()
		enemy.global_position = point.global_position

		get_parent().get_node("Enemies").add_child(enemy)
		spawned.append(enemy)

	return spawned
