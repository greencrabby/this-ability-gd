extends Node

@onready var stage_container = get_parent().get_node("StageContainer")
@onready var map_container = get_parent().get_node("MapContainer")

@onready var end_run_button = get_parent().get_node("EndRun/EndRunButton")
@onready var end_run_dialog = get_parent().get_node("EndRun/EndRunConfirmation")

var current_node: MapNode
var all_nodes: Array = []

func _ready():
	add_to_group("map_manager")
	
	end_run_button.pressed.connect(_on_end_run_pressed)
	end_run_dialog.confirmed.connect(_on_end_run_confirmed)

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
	
	var run = get_tree().get_first_node_in_group("run_manager")

	if connection.is_lateral:
		if run == null:
			print("No RunManager found!")
			return
		
		if not run.spend_money(connection.cost):
			print("Not enough money")
			return

		print("Paid:", connection.cost)

	current_node.locked = true

	lock_previous_floors(target.floor)
	
	current_node = target
	current_node.visited = true
	
	print("Entered node:", target.node_type, "ID:", target.node_id)
	update_node_visuals()
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
	for conn in current_node.get_connections():
		if conn["node"] == node and not node.locked:
			return true
	return false

func load_stage(scene: PackedScene):
	end_run_button.visible = false
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
	end_run_button.visible = true

	activate_map_camera()

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

func _on_end_run_pressed():
	end_run_dialog.popup_centered()

func _on_end_run_confirmed():
	var run = get_tree().get_first_node_in_group("run_manager")

	if run:
		run.show_end_screen(0)
