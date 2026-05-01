extends CharacterBody2D

@export var base_acceleration: float = 200.0
@export var base_max_speed: float = 300.0
@export var base_brake_force: float = 200.0
@export var base_energy_regen: float = 5.0

@export var i_frame_duration: float = 0.5
@export var weapon_pickup_scene: PackedScene

@export var faction: String = "player"

var acceleration: float
var max_speed: float
var brake_force: float
var energy_regen: float

var i_frame_timer: float = 0.0
var input_direction: Vector2 = Vector2.ZERO
var is_moving_input: bool = false
var is_dead: bool = false

@onready var flip_container = $FlipContainer
@onready var sprite = $FlipContainer/AnimatedSprite2D
@onready var weapon_pivot = $FlipContainer/WeaponPivot
@onready var weapon_slot = $FlipContainer/WeaponPivot/WeaponSlot
@onready var interaction_area = $InteractionArea

var interactables: Array = []

func _ready():
	add_to_group("player")

	var run = get_tree().get_first_node_in_group("run_manager")

	if run:
		run.set_player(self)

	apply_relics()

	# restore weapon
	if run and run.current_weapon_scene:
		equip_weapon(run.current_weapon_scene)

	interaction_area.area_entered.connect(_on_area_entered)
	interaction_area.area_exited.connect(_on_area_exited)

func apply_relics():
	var run = get_tree().get_first_node_in_group("run_manager")

	# reset base
	acceleration = base_acceleration
	max_speed = base_max_speed
	brake_force = base_brake_force
	energy_regen = base_energy_regen

	if run == null:
		return

	for relic in run.relics:
		if relic.has_method("modify_acceleration"):
			acceleration = relic.modify_acceleration(acceleration, self)

		if relic.has_method("modify_max_speed"):
			max_speed = relic.modify_max_speed(max_speed, self)

		if relic.has_method("modify_brake_force"):
			brake_force = relic.modify_brake_force(brake_force, self)

		if relic.has_method("modify_energy_regen"):
			energy_regen = relic.modify_energy_regen(energy_regen, self)

func _process(delta):
	update_aim()

	if Input.is_action_just_pressed("interact"):
		try_interact()

	if i_frame_timer > 0:
		i_frame_timer -= delta
		if i_frame_timer <= 0:
			sprite.modulate = Color(1,1,1)

func _physics_process(delta):
	handle_input()
	handle_movement(delta)
	handle_sprite()
	try_attack()
	move_and_slide()

func handle_input():
	input_direction = Vector2.ZERO

	if Input.is_action_pressed("move_up"):
		input_direction.y -= 1
	if Input.is_action_pressed("move_down"):
		input_direction.y += 1
	if Input.is_action_pressed("move_left"):
		input_direction.x -= 1
	if Input.is_action_pressed("move_right"):
		input_direction.x += 1

	input_direction = input_direction.normalized()
	is_moving_input = input_direction != Vector2.ZERO

func handle_sprite():
	if is_dead:
		sprite.play("death")
		return

	var is_sliding = velocity.length() > 10
	var is_moving = is_moving_input

	if is_sliding and !is_moving:
		sprite.play("move_attack")
	elif is_sliding:
		sprite.play("move")
	else:
		sprite.play("idle")

	if velocity.x < 0:
		flip_container.scale.x = -1
	elif velocity.x > 0:
		flip_container.scale.x = 1

func handle_movement(delta):
	if is_moving_input:
		velocity += input_direction * acceleration * delta

	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

	if Input.is_action_pressed("brake"):
		velocity = velocity.move_toward(Vector2.ZERO, brake_force * delta)

func try_attack():
	if not Input.is_action_pressed("attack"):
		return

	if is_moving_input:
		return

	var weapon = get_current_weapon()
	if weapon == null:
		return

	var run = get_tree().get_first_node_in_group("run_manager")
	if run == null:
		return

	var cost = weapon.get_energy_cost()

	if run.energy < cost:
		return

	var did_fire = weapon.fire(self)

	if did_fire:
		run.use_energy(cost)

func take_damage(amount, source):
	if i_frame_timer > 0 or is_dead:
		return

	var run = get_tree().get_first_node_in_group("run_manager")

	if run:
		run.damage(amount)

	if run.health <= 0:
		is_dead = true
		sprite.play("death")
		set_physics_process(false)
		if weapon_slot.get_child_count() > 0:
			var old_weapon = weapon_slot.get_child(0)
			old_weapon.queue_free()
		
		await sprite.animation_finished
		
		var manager = get_tree().get_first_node_in_group("run_manager")
		if manager:
			manager.on_run_failed()

	sprite.modulate = Color(1,0.3,0.3)
	i_frame_timer = i_frame_duration

func equip_weapon(new_weapon_scene: PackedScene) -> PackedScene:
	var run = get_tree().get_first_node_in_group("run_manager")

	var old_weapon_scene: PackedScene = null

	if weapon_slot.get_child_count() > 0:
		var old_weapon = weapon_slot.get_child(0)

		# store scene BEFORE deleting
		old_weapon_scene = load(old_weapon.scene_file_path)

		old_weapon.queue_free()

	var new_weapon = new_weapon_scene.instantiate()
	weapon_slot.add_child(new_weapon)

	if run:
		run.current_weapon_scene = new_weapon_scene

	return old_weapon_scene

func get_current_weapon():
	return weapon_slot.get_child(0) if weapon_slot.get_child_count() > 0 else null

func _on_area_entered(area):
	if area.is_in_group("interactable"):
		interactables.append(area)

func _on_area_exited(area):
	if area in interactables:
		interactables.erase(area)

func try_interact():
	interactables = interactables.filter(func(obj): return is_instance_valid(obj))

	if interactables.is_empty():
		return

	var closest = interactables[0]
	var min_dist = global_position.distance_to(closest.global_position)

	for obj in interactables:
		var dist = global_position.distance_to(obj.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = obj

	if closest and closest.has_method("interact"):
		closest.interact(self)

func update_aim():
	weapon_pivot.look_at(get_global_mouse_position())
