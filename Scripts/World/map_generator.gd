extends Node

@export var node_scene: PackedScene
@export var level_configs: Array[LevelConfig]

var current_level_index: int = 0

var all_nodes: Array = []
var floor_nodes: Array = []

var total_duels_spawned: int = 0

@onready var map_container = get_parent().get_node("MapContainer")

func _ready():
	add_to_group("map_generator")

func generate():
	clear_old()

	floor_nodes.clear()
	total_duels_spawned = 0

	var config = level_configs[current_level_index]

	var floors = config.floors
	var floor_configs = config.floor_configs
	var max_total_duels = config.max_total_duels

	var start_config = floor_configs[0]
	var start_count = randi_range(start_config.min_nodes, start_config.max_nodes)

	var first_floor = []
	for i in range(start_count):
		var node = create_node(0, MapNode.NodeType.COMBAT)
		first_floor.append(node)

	floor_nodes.append(first_floor)
	layout_floor(first_floor, 0)

	for f in range(1, floors):
		var prev_floor = floor_nodes[f - 1]
		var new_floor = generate_floor_nodes(f, floor_configs, max_total_duels)

		connect_floors(prev_floor, new_floor)
		add_lateral_connections(new_floor)

		floor_nodes.append(new_floor)
		layout_floor(new_floor, f)

	var shop = create_node(floors, MapNode.NodeType.SHOP)

	for node in floor_nodes[floors - 1]:
		link_nodes(node, shop, false)

	floor_nodes.append([shop])

	var boss = create_node(floors + 1, MapNode.NodeType.BOSS)
	link_nodes(shop, boss, false)

	floor_nodes.append([boss])
	
	layout_floor([shop], floors)
	layout_floor([boss], floors + 1)

	print("Map generated")

	var manager = get_tree().get_first_node_in_group("map_manager")
	if manager:
		manager.set_nodes(all_nodes)

func generate_floor_nodes(floor_index: int, floor_configs, max_total_duels) -> Array:
	var config = floor_configs[min(floor_index, floor_configs.size() - 1)]
	var nodes = []

	var count = randi_range(config.min_nodes, config.max_nodes)

	var duel_count = 0
	var encounter_count = 0

	for i in range(count):
		var type = pick_node_type(config, duel_count, encounter_count, max_total_duels)

		if type == MapNode.NodeType.DUEL:
			duel_count += 1
			total_duels_spawned += 1
		
		if type == MapNode.NodeType.ENCOUNTER:
			encounter_count += 1

		var node = create_node(floor_index, type)
		nodes.append(node)

	return nodes

func pick_node_type(config: FloorConfig, duel_count: int, encounter_count: int, max_total_duels: int):
	var weights = {}

	weights[MapNode.NodeType.COMBAT] = config.combat_weight
	weights[MapNode.NodeType.ENCOUNTER] = config.encounter_weight
	weights[MapNode.NodeType.DUEL] = config.duel_weight

	if duel_count >= config.max_duel_nodes:
		weights[MapNode.NodeType.DUEL] = 0
	
	if encounter_count >= config.max_encounter_nodes:
		weights[MapNode.NodeType.ENCOUNTER] = 0

	if total_duels_spawned >= max_total_duels:
		weights[MapNode.NodeType.DUEL] = 0

	return weighted_pick(weights)

func weighted_pick(weights: Dictionary):
	var total: float = 0.0
	for w in weights.values():
		total += w

	if total <= 0.0:
		return MapNode.NodeType.COMBAT

	var roll = randf_range(0.0, total)
	var current = 0.0

	for key in weights.keys():
		current += weights[key]
		if roll <= current:
			return key

	return MapNode.NodeType.COMBAT

func connect_floors(prev_floor, next_floor):
	var prev_count = prev_floor.size()
	var next_count = next_floor.size()

	for next in next_floor:
		var closest_prev = prev_floor[0]
		var min_dist = abs(next.position.y - closest_prev.position.y)

		for prev in prev_floor:
			var dist = abs(next.position.y - prev.position.y)
			if dist < min_dist:
				min_dist = dist
				closest_prev = prev

		link_nodes(closest_prev, next, false)

	for prev in prev_floor:
		var has_connection = false

		for conn in prev.connections:
			if conn.target in next_floor:
				has_connection = true
				break

		if not has_connection:
			var closest_next = next_floor[0]
			var min_dist = abs(prev.position.y - closest_next.position.y)

			for next in next_floor:
				var dist = abs(prev.position.y - next.position.y)
				if dist < min_dist:
					min_dist = dist
					closest_next = next

			link_nodes(prev, closest_next, false)

func add_lateral_connections(nodes):
	for i in range(nodes.size() - 1):
		var chance = 0.6

		if nodes.size() >= 4:
			chance = 0.4

		if randf() < chance:
			var a = nodes[i]
			var b = nodes[i + 1]

			link_nodes(a, b, true)
			link_nodes(b, a, true)

func link_nodes(a: MapNode, b: MapNode, lateral: bool):
	var conn = Connection.new()
	conn.target = b
	conn.is_lateral = lateral
	
	if lateral:
		conn.cost = randi_range(5, 20)

	a.connections.append(conn)

func create_node(floor: int, type):
	var node = node_scene.instantiate()
	map_container.add_child(node)

	node.floor = floor
	node.node_type = type
	node.update_visual()
	node.node_id = all_nodes.size()
	
	node.locked = false
	node.visited = false

	node.stage_scene = pick_stage_scene(type)

	node.add_to_group("map_node")

	all_nodes.append(node)
	return node

func clear_old():
	for child in map_container.get_children():
		child.queue_free()

	all_nodes.clear()

func pick_stage_scene(type):
	var config = level_configs[current_level_index]

	match type:
		MapNode.NodeType.COMBAT:
			return config.combat_scenes.pick_random()
		MapNode.NodeType.ENCOUNTER:
			return config.encounter_scenes.pick_random()
		MapNode.NodeType.DUEL:
			return config.duel_scenes.pick_random()
		MapNode.NodeType.SHOP:
			return config.shop_scene
		MapNode.NodeType.BOSS:
			return config.boss_scene

	return null

func layout_floor(nodes: Array, floor_index: int):
	var spacing_x = 250
	var spacing_y = 120
	
	var start_y = -((nodes.size() - 1) * spacing_y) / 2.0

	for i in range(nodes.size()):
		var node = nodes[i]
		node.position = Vector2(
			floor_index * spacing_x,
			start_y + i * spacing_y
		)

func go_to_next_level():
	call_deferred("_go_to_next_level_impl")

func _go_to_next_level_impl():
	current_level_index += 1

	if current_level_index >= level_configs.size():
		var manager = get_tree().get_first_node_in_group("run_manager")
		if manager:
			manager.on_run_success()
		return

	generate()

	var map_camera = get_tree().current_scene.get_node_or_null("MapCamera")
	if map_camera:
		map_camera.global_position = Vector2.ZERO

	var map_manager = get_tree().get_first_node_in_group("map_manager")
	if map_manager:
		map_manager.return_to_map()

func show_victory():
	get_tree().paused = true
