extends Area2D

@export var weapon_scene: PackedScene

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	var temp_weapon = weapon_scene.instantiate()
	
	if temp_weapon.display_texture:
		sprite.texture = temp_weapon.display_texture
	
	temp_weapon.queue_free()

func interact(player):
	player.interactables.erase(self)

	var dropped_scene = player.equip_weapon(weapon_scene)

	# 🔻 Drop old weapon if exists
	if dropped_scene != null:
		var pickup = preload("res://Scenes/Weaponry/WeaponPickup.tscn").instantiate()
		pickup.weapon_scene = dropped_scene
		get_tree().get_first_node_in_group("stage_root").add_child(pickup)
		pickup.global_position = global_position

	queue_free()
