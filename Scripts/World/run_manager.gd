extends Node
class_name RunManager

var player: CharacterBody2D
var run_started: bool = false
@export var end_screen_scene: PackedScene

var selected_starter_pack: StarterPack
@export var all_possible_skills: Array[SkillNode] = []

var money: int = 0

var base_max_health: int = 100
var max_health: int = 100
var health: float = 100

var base_max_energy: float = 100
var max_energy: float = 100
var energy: float = 100

var current_weapon_scene: PackedScene

var relics: Array[RelicBase] = []

signal health_changed
signal energy_changed
signal money_changed
signal relics_changed

# Skill tree
var floors_cleared: int = 0
var enemies_killed: int = 0

func _ready():
	add_to_group("run_manager")

func start_run():
	if run_started:
		return
	
	MusicManager.play_track("gameplay")
	run_started = true
	
	if selected_starter_pack == null:
		push_error("No starter pack selected!")
		return
		
	apply_tree_upgrades()
	
	money += selected_starter_pack.starting_money
	
	current_weapon_scene = selected_starter_pack.starting_weapon
	
	for relic in selected_starter_pack.starting_relics:
		relics.append(relic)

	print("Run started with:", selected_starter_pack.pack_name)

func apply_tree_upgrades():
	for skill in MetaManager.unlocked_resources:
		if skill.associated_relic:
			add_relic(skill.associated_relic)

# Player Link
func set_player(p):
	player = p
	emit_signal("health_changed")
	emit_signal("energy_changed")

# HP
func damage(amount: float):
	health = max(health - amount, 0)
	emit_signal("health_changed")

func heal(amount: float):
	health = min(health + amount, max_health)
	emit_signal("health_changed")

# Energy
func use_energy(amount: float) -> bool:
	if energy < amount:
		return false
	
	energy -= amount
	emit_signal("energy_changed")
	return true

func gain_energy(amount: float):
	energy = min(energy + amount, max_energy)
	emit_signal("energy_changed")

# Money
func add_money(amount: int):
	money += amount
	emit_signal("money_changed")

func spend_money(amount: int) -> bool:
	if money < amount:
		return false
	
	money -= amount
	emit_signal("money_changed")
	return true

# Relics
func add_relic(new_relic: RelicBase):
	for r in relics:
		if r.resource_path == new_relic.resource_path:
			print("Duplicate relic blocked:", new_relic.relic_name)
			return false
	
	relics.append(new_relic)

	recalculate_stats()
	emit_signal("relics_changed")
	return true

# Recalculation
func recalculate_stats():
	max_health = base_max_health
	max_energy = base_max_energy

	for relic in relics:
		if relic.has_method("modify_max_health"):
			max_health = relic.modify_max_health(max_health, self)
		
		if relic.has_method("modify_max_energy"):
			max_energy = relic.modify_max_energy(max_energy, self)

	health = clamp(health, 0, max_health)
	energy = clamp(energy, 0, max_energy)

	emit_signal("health_changed")
	emit_signal("energy_changed")

# Energy Regen
func _process(delta):
	if player:
		var regen = player.energy_regen
		gain_energy(regen * delta)

# Skill tree
func calculate_points() -> int:
	var points = 0
	
	points += floors_cleared * 2
	points += enemies_killed * 1
	
	print("Points earned:", points)
	return points

func on_run_failed():
	var points = calculate_points()
	
	MetaManager.add_points(points)
	
	var manager = get_tree().get_first_node_in_group("map_manager")
	if manager:
		manager.return_to_map()
		
	show_end_screen(points)

func on_run_success():
	var points = calculate_points()
	points += 100
	
	MetaManager.add_points(points)
	
	var manager = get_tree().get_first_node_in_group("map_manager")
	if manager:
		manager.return_to_map()
		
	show_end_screen(points)
	
func show_end_screen(points):
	MusicManager.play_track("main_menu", 3.0)
	EndScreen.points_to_display = points
	get_tree().change_scene_to_packed(end_screen_scene)
