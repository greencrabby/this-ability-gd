extends Node2D

@export var price: int = 50
@export var pickup_scene: PackedScene

var item_resource = null
var is_weapon: bool = false

var player_in_range: bool = false

@onready var price_label = $Label
@onready var sprite = $Sprite2D
@onready var coin_icon = $CoinSprite

func _ready():
	price_label.visible = false
	coin_icon.visible = false

func setup(resource, texture, cost, weapon := false):
	item_resource = resource
	sprite.texture = texture
	price = cost
	price_label.text = str(price)
	is_weapon = weapon

func _input(event):
	if player_in_range and event.is_action_pressed("interact"):
		try_buy()

func try_buy():
	var run = get_tree().get_first_node_in_group("run_manager")
	if run == null:
		print("No RunManager found!")
		return
	
	if not run.spend_money(price):
		print("Not enough money")
		return
	
	print("Bought for:", price)

	spawn_pickup()
	queue_free()

func spawn_pickup():
	var pickup = pickup_scene.instantiate()
	
	if is_weapon:
		pickup.weapon_scene = item_resource
	else:
		pickup.relic = item_resource
	
	get_parent().add_child(pickup)
	pickup.global_position = global_position + Vector2(0, -40)

func _on_area_entered(body):
	if body.is_in_group("player"):
		price_label.visible = true
		coin_icon.visible = true
		player_in_range = true

func _on_area_exited(body):
	if body.is_in_group("player"):
		price_label.visible = false
		coin_icon.visible = false
		player_in_range = false
