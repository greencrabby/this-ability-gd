extends Area2D

class_name PotionPickup

enum PotionType {
	SMALL,
	LARGE
}

@export var potion_type: PotionType = PotionType.SMALL

@export var small_heal: int = 25
@export var large_heal: int = 60

@export var small_texture: Texture2D
@export var large_texture: Texture2D

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	add_to_group("interactable")	
	update_visual()

func setup(type):
	potion_type = type
	update_visual()

func update_visual():
	if sprite == null:
		await ready
	
	sprite.scale = Vector2(1,1)
	sprite.modulate = Color(1,1,1,1)
	sprite.z_index = 10

	match potion_type:
		PotionType.SMALL:
			sprite.texture = small_texture
		PotionType.LARGE:
			sprite.texture = large_texture

func interact(player):
	var run = get_tree().get_first_node_in_group("run_manager")
	if run == null:
		return

	var heal_amount = 0

	match potion_type:
		PotionType.SMALL:
			heal_amount = small_heal
		PotionType.LARGE:
			heal_amount = large_heal

	run.heal(heal_amount)

	print("Healed for:", heal_amount)

	queue_free()
