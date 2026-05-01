class_name Chest
extends Node2D

enum ChestType {
	NOT_RARE,
	RARE,
	RARER
}

@export var chest_type: ChestType

@onready var sprite: Sprite2D = $Sprite2D

@export var common_texture: Texture2D
@export var rare_texture: Texture2D
@export var rarer_texture: Texture2D	

@export var weapon_pickup_scene: PackedScene
@export var relic_pickup_scene: PackedScene
@export var potion_pickup_scene: PackedScene

@export var weapon_pool: Array[PackedScene]
@export var relic_pool: Array[RelicBase]
@export var boss_weapon_pool: Array[PackedScene]

var opened: bool = false

func _ready():
	update_visual()

func setup(type):
	chest_type = type
	if sprite == null:
		await ready
	update_visual()  # 🔥 force refresh AFTER assignment

func update_visual():
	match chest_type:
		ChestType.NOT_RARE:
			sprite.texture = common_texture
		ChestType.RARE:
			sprite.texture = rare_texture
		ChestType.RARER:
			sprite.texture = rarer_texture

# =========================
# ENTRY
# =========================
func _on_area_entered(body):
	if opened:
		return
		
	if not body.is_in_group("player"):
		return

	opened = true
	open_chest(body)

func open_chest(player):
	print("Opening chest:", chest_type)

	match chest_type:
		ChestType.NOT_RARE:
			give_common_loot(player)
		ChestType.RARE:
			give_rare_loot(player)
		ChestType.RARER:
			give_rarer_loot(player)

	queue_free()

# =========================
# LOOT LOGIC
# =========================

func give_common_loot(player):
	match randi_range(0, 3):
		0: spawn_weapon(Rarity.Type.COMMON)
		1: give_currency(player, randi_range(10, 100))
		2: spawn_relic(Rarity.Type.COMMON)
		3: spawn_potion()

func give_rare_loot(player):
	give_currency(player, randi_range(30, 60))

	if randf() < 0.5:
		spawn_weapon(Rarity.Type.RARE)
	else:
		spawn_relic(Rarity.Type.RARE)

func give_rarer_loot(player):
	give_currency(player, randi_range(60, 120))

	spawn_weapon(Rarity.Type.RARE)
	spawn_relic(Rarity.Type.RARE)

	# 🎯 upgrade chances
	if randf() < 0.25:
		spawn_weapon(Rarity.Type.LEGENDARY)

	if randf() < 0.25:
		spawn_relic(Rarity.Type.LEGENDARY)

	# 👑 boss exclusive relic
	if is_boss_stage() and randf() < 0.3:
		spawn_relic(Rarity.Type.BOSS, true)

	# 🎯 boss weapon chance (your original system, kept)
	if is_boss_stage() and randf() < 0.15:
		spawn_boss_weapon()

# =========================
# SPAWN HELPERS
# =========================

func spawn_weapon(target_rarity: int):
	var valid = []

	for weapon_scene in weapon_pool:
		var weapon = weapon_scene.instantiate()

		if weapon.rarity == target_rarity:
			valid.append(weapon_scene)

		weapon.queue_free()

	if valid.is_empty():
		print("No weapon of rarity:", target_rarity)
		return

	var pickup = weapon_pickup_scene.instantiate()
	pickup.weapon_scene = valid.pick_random()
	get_parent().add_child(pickup)

func spawn_relic(target_rarity: int, allow_boss := false):
	var run = get_tree().get_first_node_in_group("run_manager")

	var valid = []

	for relic in relic_pool:
		# ❌ rarity mismatch
		if relic.rarity != target_rarity:
			continue

		# ❌ duplicate prevention
		var already_has = false
		for owned in run.relics:
			if owned.resource_path == relic.resource_path:
				already_has = true
				break

		if not already_has:
			valid.append(relic)

	if valid.is_empty():
		print("No valid relics!")
		return

	var pickup = relic_pickup_scene.instantiate()
	pickup.relic = valid.pick_random()
	get_parent().add_child(pickup)

func spawn_boss_weapon():
	if boss_weapon_pool.is_empty():
		return
	
	var pickup = weapon_pickup_scene.instantiate()
	pickup.weapon_scene = boss_weapon_pool.pick_random()
	get_parent().add_child(pickup)

func give_currency(player, amount):
	var run = get_tree().get_first_node_in_group("run_manager")
	if run:
		run.add_money(amount)
	else:
		push_error("RunManager not found!")

func spawn_potion():
	if potion_pickup_scene == null:
		return
	
	var pickup = potion_pickup_scene.instantiate()
	get_parent().add_child(pickup)

	pickup.global_position = global_position

	if randf() < 0.7:
		pickup.setup(pickup.PotionType.SMALL)
	else:
		pickup.setup(pickup.PotionType.LARGE)

# =========================
# HELPERS
# =========================

func is_boss_stage():
	var stage = get_tree().current_scene
	
	if stage.has_node("StageController"):
		var controller = stage.get_node("StageController")
		if controller.current_node:
			return controller.current_node.node_type == MapNode.NodeType.BOSS
	
	return false
