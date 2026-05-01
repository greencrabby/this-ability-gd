extends CharacterBody2D

var damage: float = 0
var shooter = null

@export var max_bounces: int = 0

var bounce_count: int = 0

@onready var sprite: Sprite2D = $Sprite2D

var base_speed: float = 0.0
var faction: String = ""

@export var damage_number_scene: PackedScene

func _ready():
	apply_speed_modifiers()

func _physics_process(delta):
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		handle_collision(collision)

func handle_collision(collision):
	var collider = collision.get_collider()

	if collider == shooter:
		return

	if collider.has_method("deflect_bullet"):
		collider.deflect_bullet(self)
		queue_free()
		return

	if bounce_count < max_bounces:
		velocity = velocity.bounce(collision.get_normal())
		bounce_count += 1
	else:
		queue_free()

func deflect_bullet(new_direction: Vector2):
	velocity = new_direction * velocity.length()

func _on_hit(body):
	if body == shooter:
		return
	
	if "faction" in body and body.faction == faction:
		return
	
	if body.has_method("take_damage"):
		body.take_damage(damage, shooter)
		if "faction" in body and body.faction != "player":
			spawn_damage_number(body.global_position, damage)
		queue_free()

func apply_speed_modifiers():
	var final_speed = base_speed

	# 🟢 shooter-based buffs (player relics)
	if shooter and "relics" in shooter:
		for relic in shooter.relics:
			if relic.has_method("modify_bullet_speed"):
				final_speed = relic.modify_bullet_speed(final_speed, self, shooter)

	# 🔴 player defensive effects (slow enemy bullets)
	var player = get_tree().get_first_node_in_group("player")
	if player and faction == "enemy":
		for relic in player.relics:
			if relic.has_method("modify_incoming_bullet_speed"):
				final_speed = relic.modify_incoming_bullet_speed(final_speed, self, player)

	# 🔁 apply result
	velocity = velocity.normalized() * final_speed

func spawn_damage_number(pos: Vector2, amount: float):
	if damage_number_scene == null:
		return
	
	var dmg = damage_number_scene.instantiate()
	get_tree().current_scene.add_child(dmg)
	
	dmg.global_position = pos
	dmg.setup(amount)
