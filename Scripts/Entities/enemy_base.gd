class_name EnemyBase
extends CharacterBody2D

@export var max_health: float = 10
@export var knockback_friction: float = 800.0
@export var knockback_resistance: float = 1.0
@export var faction: String = "enemy"

var current_health: float
var knockback_velocity: Vector2 = Vector2.ZERO
var player = null

signal died

func _ready():
	add_to_group("enemy")
	current_health = max_health
	
	await get_tree().process_frame 
	
	player = get_tree().get_first_node_in_group("player")
	
	if player == null:
		push_error("Enemy: Player not found!")

func take_damage(amount, source):
	if current_health <= 0:
		return
		
	current_health -= amount
	
	if current_health <= 0:
		die()

func die():
	emit_signal("died")
	queue_free()

func apply_knockback(force: Vector2):
	knockback_velocity = force * (1.0 - knockback_resistance)

func can_see_player() -> bool:
	if player == null:
		return false
	
	var space_state = get_world_2d().direct_space_state
	
	var query = PhysicsRayQueryParameters2D.create(
		global_position,
		player.global_position
	)
	
	query.exclude = [self]
	
	var result = space_state.intersect_ray(query)
	
	if result.is_empty():
		return true
	
	if result.collider == player:
		return true
	
	return false
