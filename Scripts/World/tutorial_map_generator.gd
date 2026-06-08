extends Node

@export var node_scene: PackedScene

@export var combat_stage: PackedScene
@export var encounter_stage: PackedScene
@export var shop_stage: PackedScene
@export var completion_stage: PackedScene

var all_nodes: Array = []

@onready var map_container = get_parent().get_node("MapContainer")

func _ready():
	add_to_group("map_generator")

func generate():
	clear_old()

	var combat = create_node(
		0,
		MapNode.NodeType.COMBAT,
		combat_stage
	)

	var encounter = create_node(
		1,
		MapNode.NodeType.ENCOUNTER,
		encounter_stage
	)

	var shop = create_node(
		2,
		MapNode.NodeType.SHOP,
		shop_stage
	)

	var boss = create_node(
		3,
		MapNode.NodeType.BOSS,
		completion_stage
	)

	link_nodes(combat, encounter)
	link_nodes(encounter, shop)
	link_nodes(shop, boss)

	layout_node(combat, 0)
	layout_node(encounter, 1)
	layout_node(shop, 2)
	layout_node(boss, 3)

	var manager = get_tree().get_first_node_in_group("map_manager")
	if manager:
		manager.set_nodes(all_nodes)

func create_node(floor, type, scene):
	var node = node_scene.instantiate()

	map_container.add_child(node)

	node.floor = floor
	node.node_type = type
	node.stage_scene = scene

	node.node_id = all_nodes.size()

	node.locked = false
	node.visited = false

	node.update_visual()

	all_nodes.append(node)

	return node

func link_nodes(a, b):
	var conn = Connection.new()

	conn.target = b
	conn.is_lateral = false
	conn.cost = 0

	a.connections.append(conn)

func layout_node(node, floor):
	node.position = Vector2(
		floor * 250,
		0
	)

func clear_old():
	for child in map_container.get_children():
		child.queue_free()

	all_nodes.clear()

func go_to_next_level():
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")
