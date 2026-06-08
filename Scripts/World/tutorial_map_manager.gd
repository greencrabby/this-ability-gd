extends Node

@onready var stage_container = get_parent().get_node("StageContainer")
@onready var map_container = get_parent().get_node("MapContainer")

@onready var tutorial_label = get_parent().get_node_or_null("TutorialLayer/TutorialLabel")

var current_node: MapNode
var all_nodes: Array = []

func _ready():
	add_to_group("map_manager")

	show_message(
		"Welcome!\nClick the first node to begin."
	)

func show_message(text: String):
	if tutorial_label:
		tutorial_label.text = text

func choose_start(start_node: MapNode):
	current_node = start_node
	current_node.visited = true
	current_node.locked = false

	for node in all_nodes:
		if node.floor == start_node.floor and node != start_node:
			node.locked = true

	update_node_visuals()

	load_stage(start_node.stage_scene)

	show_message(
		"Move with WASD and hold space to brake.\nPress E to pick up the pistol and relic, and defeat the dummy enemy. \nYou cant attack whilst holding down movement keys. \nUsing a weapon will require energy based on how much energy cost the weapon has. \nBut no worries, energy will regenerate overtime"
	)

func set_nodes(nodes: Array):
	all_nodes = nodes
	current_node = null

	for node in all_nodes:
		if not node.node_selected.is_connected(_on_node_selected):
			node.node_selected.connect(_on_node_selected)

	update_node_visuals()

func _on_node_selected(node: MapNode):
	print("Clicked:", node.node_id)

	if current_node == null:
		if node.floor != 0:
			print("Must start from floor 0!")
			return

		choose_start(node)
		return

	move_to(node)

func move_to(target: MapNode):
	if target.locked:
		print("Node locked")
		return

	var connection = get_connection(current_node, target)

	if connection == null:
		print("No connection")
		return

	current_node.locked = true

	lock_previous_floors(target.floor)

	current_node = target
	current_node.visited = true

	update_node_visuals()

	match target.node_type:
		MapNode.NodeType.ENCOUNTER:
			show_message(
				"Encounter rooms contain free rewards. Chests can contain money, potions to regenerate health, relics, weapons, or maybe even all of them"
			)

		MapNode.NodeType.SHOP:
			show_message(
				"Spend money here to purchase upgrades. Remember, you get money from clearing stages or chests"
			)

		MapNode.NodeType.BOSS:
			show_message(
				"Congratulations! You completed the tutorial. \nNormally when you clear a floor, you will enter another floor until the run ends or you reach the final floor, and you get points to spend on the skill tree"
			)

	load_stage(target.stage_scene)

	var camera = get_viewport().get_camera_2d()
	if camera:
		camera.global_position = target.global_position

func get_connection(from: MapNode, to: MapNode):
	for conn in from.get_connections():
		if conn["node"] == to:
			return conn

	return null

func lock_previous_floors(floor: int):
	for node in all_nodes:
		if node.floor < floor:
			node.locked = true

func is_reachable(node: MapNode) -> bool:
	if current_node == null:
		return false

	for conn in current_node.get_connections():
		if conn["node"] == node and not node.locked:
			return true

	return false

func load_stage(scene: PackedScene):
	map_container.visible = false
	stage_container.visible = true

	if scene == null:
		print("No stage assigned!")
		return

	for child in stage_container.get_children():
		child.queue_free()

	var stage = scene.instantiate()

	if stage.has_node("StageController"):
		var controller = stage.get_node("StageController")
		controller.current_node = current_node

	stage_container.add_child(stage)

	var map_camera = get_parent().get_node("MapCamera")
	if map_camera:
		map_camera.make_current()

	await get_tree().process_frame

	var player = stage.get_node_or_null("Bean")

	if player:
		var stage_camera = player.get_node_or_null("StageCamera")

		if stage_camera:
			stage_camera.make_current()

func return_to_map():
	for child in stage_container.get_children():
		child.queue_free()

	map_container.visible = true
	stage_container.visible = false

	activate_map_camera()
	update_tutorial_text_after_stage()

func activate_map_camera():
	var map_camera = get_parent().get_node("MapCamera")

	if map_camera:
		map_camera.make_current()

func update_node_visuals():
	for node in all_nodes:
		if node.locked:
			node.visual_state = MapNode.VisualState.LOCKED

		elif node == current_node:
			node.visual_state = MapNode.VisualState.CURRENT

		elif current_node != null and is_reachable(node):
			node.visual_state = MapNode.VisualState.REACHABLE

		else:
			node.visual_state = MapNode.VisualState.NORMAL

		node.update_visual()

func update_tutorial_text_after_stage():
	if current_node == null:
		return

	match current_node.floor:
		0:
			show_message(
				"Great! Click the Encounter node. You are unable to enter to the combat node after clearing it"
			)

		1:
			show_message(
				"Good job! Click the Shop node. You also get money and regenerate health after clearing a node"
			)

		2:
			show_message(
				"Now enter the final node. Sometimes, some nodes will have vertical paths connecting each other. Those paths require you to spend money"
			)
