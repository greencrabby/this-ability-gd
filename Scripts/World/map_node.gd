class_name MapNode
extends Node2D

signal node_selected(node)

@export var node_id: int
@export var floor: int
var connections: Array = []

var visited: bool = false
var locked: bool = false

enum NodeType {
	COMBAT,
	ENCOUNTER,
	DUEL,
	SHOP,
	BOSS
}

@export var node_type: NodeType
var stage_scene: PackedScene

@onready var area: Area2D = $Area2D

@export var combat_texture: Texture2D
@export var encounter_texture: Texture2D
@export var duel_texture: Texture2D
@export var shop_texture: Texture2D
@export var boss_texture: Texture2D

@onready var sprite = $Sprite2D

enum VisualState {
	NORMAL,
	CURRENT,
	REACHABLE,
	LOCKED
}

var visual_state: VisualState = VisualState.NORMAL

func _ready():
	add_to_group("map_node")
	update_visual()
	area.input_event.connect(_on_input_event)

func _process(delta):
	queue_redraw()

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		emit_signal("node_selected", self)

func get_connections():
	var result = []
	for conn in connections:
		if is_instance_valid(conn.target):
			result.append({
				"node": conn.target,
				"cost": conn.cost,
				"is_lateral": conn.is_lateral
			})
	return result

func _draw():
	for conn in connections:
		var target = conn.target
		if is_instance_valid(target):
			draw_line(Vector2.ZERO, to_local(target.global_position), Color.WHITE, 2)

func update_visual():
	# 🖼 texture by type
	match node_type:
		NodeType.COMBAT:
			sprite.texture = combat_texture
		NodeType.ENCOUNTER:
			sprite.texture = encounter_texture
		NodeType.DUEL:
			sprite.texture = duel_texture
		NodeType.SHOP:
			sprite.texture = shop_texture
		NodeType.BOSS:
			sprite.texture = boss_texture

	# 📏 scale (safe check)
	if sprite.texture:
		var target_size = Vector2(64, 64)
		var tex_size = sprite.texture.get_size()
		sprite.scale = target_size / tex_size

	# 🎨 COLOR by state
	match visual_state:
		VisualState.CURRENT:
			sprite.modulate = Color(1, 1, 0.4)   # yellow glow
		VisualState.REACHABLE:
			sprite.modulate = Color(0.6, 1, 1)   # light blue
		VisualState.LOCKED:
			sprite.modulate = Color(0.3, 0.3, 0.3) # gray
		VisualState.NORMAL:
			sprite.modulate = Color(1, 1, 1)
