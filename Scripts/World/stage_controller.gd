extends Node

var enemies_alive: int = 0
var cleared: bool = false

@export var shop_item_scene: PackedScene
@export var weapon_pool: Array[PackedScene]
@export var relic_pool: Array[RelicBase]

@export var weapon_pickup_scene: PackedScene
@export var relic_pickup_scene: PackedScene

@onready var exit_area = $"../ExitArea"
@onready var reward_spawner = $"../RewardSpawner"
@onready var shop_points = $"../ShopPoints"
@onready var enemy_show = $"../CanvasLayer/Control/ColorRect"
@onready var enemy_label = $"../CanvasLayer/Control/ColorRect/EnemyCounter"
@onready var clear_label = $"../CanvasLayer/Control/ClearMessage"

var current_node: MapNode

func _ready():
	exit_area.body_entered.connect(_on_exit_entered)

	if current_node == null:
		push_error("StageController: current_node is NULL")
		return

	if current_node.node_type == MapNode.NodeType.SHOP:
		cleared = true
		exit_area.monitoring = true
		spawn_shop_items()
		enemy_show.visible = false
		clear_label.visible = false
		return

	exit_area.monitoring = false
	exit_area.visible = false

	if current_node.node_type in [
		MapNode.NodeType.COMBAT,
		MapNode.NodeType.DUEL,
		MapNode.NodeType.BOSS
	]:
		setup_enemies()
		clear_label.visible = false
	else:
		setup_encounter()

func _on_enemy_died():
	enemies_alive -= 1
	var run = get_tree().get_first_node_in_group("run_manager")
	run.enemies_killed += 1
	update_ui()
	
	if enemies_alive <= 0 and not cleared:
		clear_stage()
		if clear_label:
			clear_label.visible = true
			enemy_show.visible = false
		
		var tween = create_tween()
		clear_label.modulate.a = 0
		tween.tween_property(clear_label, "modulate:a", 1.0, 0.5)
		tween.tween_interval(2.0)
		tween.tween_property(clear_label, "modulate:a", 0.0, 1.0)

func setup_enemies():
	await get_tree().process_frame

	var spawner = get_parent().get_node_or_null("EnemySpawner")
	var enemies_node = get_parent().get_node_or_null("Enemies")

	if spawner == null or enemies_node == null:
		print("Spawner or Enemies node missing")
		return

	var player = get_tree().get_first_node_in_group("player")

	var spawned = spawner.spawn_enemies()

	enemies_alive = 0

	for e in spawned:
		if e.is_in_group("enemy"):
			enemies_alive += 1

			if not e.is_connected("died", _on_enemy_died):
				e.connect("died", _on_enemy_died)

			e.player = player

	if enemies_alive == 0:
		clear_stage()
	
	update_ui()

func clear_stage():
	if cleared:
		return
		
	cleared = true

	var chest_type = get_chest_type()
	var chest = reward_spawner.spawn_chest(chest_type)

	exit_area.monitoring = true
	exit_area.visible = true

func _on_exit_entered(body):
	if not cleared:
		return
		
	if not body.is_in_group("player"):
		return
	
	var run = get_tree().get_first_node_in_group("run_manager")
	if run:
		run.floors_cleared += 1
		run.heal(20)
		run.add_money(20)

	var generator = get_tree().get_first_node_in_group("map_generator")

	if current_node.node_type == MapNode.NodeType.BOSS:

		if generator:
			generator.go_to_next_level()
		return
	
	var manager = get_tree().get_first_node_in_group("map_manager")
	if manager:
		manager.return_to_map()

func get_chest_type():
	match current_node.node_type:
		MapNode.NodeType.COMBAT:
			return pick_weighted({
				Chest.ChestType.NOT_RARE: 70,
				Chest.ChestType.RARE: 30
			})

		MapNode.NodeType.ENCOUNTER:
			return pick_weighted({
				Chest.ChestType.NOT_RARE: 50,
				Chest.ChestType.RARE: 35,
				Chest.ChestType.RARER: 15
			})

		MapNode.NodeType.DUEL:
			return Chest.ChestType.RARER

		MapNode.NodeType.BOSS:
			return Chest.ChestType.RARER

	return Chest.ChestType.NOT_RARE

func pick_weighted(weights: Dictionary):
	var total = 0
	for v in weights.values():
		total += v

	var roll = randi_range(1, total)
	var current = 0

	for key in weights.keys():
		current += weights[key]
		if roll <= current:
			print("PICKED:", key)
			return key

	return weights.keys()[0]

func spawn_shop_items():
	if not shop_points:
		print("Error: ShopPoints node not found!")
		return

	var points = shop_points.get_children()
	if points.is_empty():
		print("Error: No P1, P2 markers found under ShopPoints!")
		return

	var weapon_count = randi_range(1, 2)
	var relic_count = clamp(points.size() - weapon_count, 1, 3)

	var index = 0
	
	var run = get_tree().get_first_node_in_group("run_manager")

	for i in range(weapon_count):
		if index >= points.size(): break
	
		var valid = weapon_pool.filter(func(w):
			var inst = w.instantiate()
			var is_rarity_ok = inst.rarity in [Rarity.Type.COMMON, Rarity.Type.RARE]
			inst.queue_free()
			return is_rarity_ok
		)

		if not valid.is_empty():
			create_shop_instance(valid.pick_random(), true, points[index].position)
			index += 1
			
	var picked_relics: Array = []

	for i in range(relic_count):
		if index >= points.size(): break
		
		var valid = relic_pool.filter(func(relic):
			if relic.rarity == Rarity.Type.BOSS:
				return false
			
			if run.relics.any(func(owned): return owned.resource_path == relic.resource_path):
				return false
			
			if picked_relics.any(func(r): return r.resource_path == relic.resource_path):
				return false
			
			return true
		)

		if valid.is_empty():
			break

		var chosen = valid.pick_random()
		picked_relics.append(chosen)

		create_shop_instance(chosen, false, points[index].position)
		index += 1

func create_shop_instance(scene_or_res, is_weapon: bool, pos: Vector2):
	var item = shop_item_scene.instantiate()
	add_child(item)
	item.position = pos
	item.z_index = 5
	
	var texture: Texture2D = null
	var price_val: int = 0
	
	if is_weapon:
		var temp_node = scene_or_res.instantiate()
		if temp_node.has_node("Sprite2D"):
			texture = temp_node.get_node("Sprite2D").texture
		price_val = randi_range(10, 100)
		temp_node.queue_free()
	else:
		texture = scene_or_res.icon
		price_val = randi_range(20, 200)
	
	item.setup(scene_or_res, texture, price_val, is_weapon)
	
	item.pickup_scene = weapon_pickup_scene if is_weapon else relic_pickup_scene

func setup_encounter():
	print("Encounter started")

	clear_stage()
	enemy_show.visible = false
	clear_label.visible = false


func update_ui():
	if enemy_label:
		if current_node.node_type in [MapNode.NodeType.SHOP, MapNode.NodeType.ENCOUNTER]:
			enemy_label.visible = false
		else:
			enemy_label.visible = true
			enemy_label.text = "Enemies Left: " + str(max(0, enemies_alive))
