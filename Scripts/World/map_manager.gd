extends Node

@onready var stage_container = get_parent().get_node("StageContainer")
@onready var map_container = get_parent().get_node("MapContainer")

var current_node: MapNode
var all_nodes: Array = []

func _ready():
	# collect all nodes in scene
	add_to_group("map_manager")

# 🔹 START SELECTION
func choose_start(start_node: MapNode):
	current_node = start_node
	current_node.visited = true
	current_node.locked = false
	
	for node in all_nodes:
		if node.floor == start_node.floor and node != start_node:
			node.locked = true
	
	update_node_visuals()

	load_stage(start_node.stage_scene)

func set_nodes(nodes: Array):
	all_nodes = nodes
	current_node = null
	
	for node in all_nodes:
		node.node_selected.connect(_on_node_selected)
	
	update_node_visuals()

func _on_node_selected(node: MapNode):
	print("Clicked:", node.node_id, "locked:", node.locked)
	if current_node == null:
		if node.floor != 0:
			print("Must start from floor 0!")
			return
		
		choose_start(node)
		return

	move_to(node)

# 🔹 MOVE
func move_to(target: MapNode):
	print("Connections from current:")
	for conn in current_node.get_connections():
		print(" ->", conn["node"].node_id, "cost:", conn["cost"])
	
	if target.locked:
		print("Node locked")
		return
	
	var connection = get_connection(current_node, target)
	if connection == null:
		print("No connection")
		return
	
	# 💰 lateral cost
	var run = get_tree().get_first_node_in_group("run_manager")

	if connection.is_lateral:
		if run == null:
			print("No RunManager found!")
			return
		
		if not run.spend_money(connection.cost):
			print("Not enough money")
			return

		print("Paid:", connection.cost)

	# 🔒 lock previous node
	current_node.locked = true

	# 🔒 lock previous floors
	lock_previous_floors(target.floor)

	# 🚶 move
	current_node = target
	current_node.visited = true
	
	print("Entered node:", target.node_type, "ID:", target.node_id)
	update_node_visuals()
	load_stage(target.stage_scene)
	
	var camera = get_viewport().get_camera_2d()
	if camera:
		camera.global_position = target.global_position

# 🔹 FIND CONNECTION
func get_connection(from: MapNode, to: MapNode):
	for conn in from.get_connections():
		if conn["node"] == to:
			return conn
	return null

# 🔒 LOCK FLOORS
func lock_previous_floors(floor: int):
	for node in all_nodes:
		if node.floor < floor:
			node.locked = true

# 🔹 HELPER
func is_reachable(node: MapNode) -> bool:
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

	# clear old stage
	for child in stage_container.get_children():
		child.queue_free()

	var stage = scene.instantiate()
	
	if stage.has_node("StageController"):
		var controller = stage.get_node("StageController")
		controller.current_node = current_node

	stage_container.add_child(stage)

	# 🔴 turn OFF map camera
	var map_camera = get_parent().get_node("MapCamera")
	if map_camera:
		map_camera.make_current()

	# 🟢 wait for player to exist, then enable its camera
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

func activate_map_camera():
	var map_camera = get_parent().get_node("MapCamera")
	if map_camera:
		map_camera.make_current()

func update_node_visuals():
	for node in all_nodes:
		# 🔒 locked nodes
		if node.locked:
			node.visual_state = MapNode.VisualState.LOCKED

		# 🟢 current node
		elif node == current_node:
			node.visual_state = MapNode.VisualState.CURRENT

		# 🔵 reachable nodes
		elif current_node != null and is_reachable(node):
			node.visual_state = MapNode.VisualState.REACHABLE

		# ⚪ default
		else:
			node.visual_state = MapNode.VisualState.NORMAL

		node.update_visual()
