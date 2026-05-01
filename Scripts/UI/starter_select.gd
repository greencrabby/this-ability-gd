extends Control

@export var starter_packs: Array[StarterPack]
@export var card_scene: PackedScene

@onready var buttons_holder = $VBoxContainer/HBoxContainer
@onready var desc_label = $VBoxContainer/Label2
@onready var start_button = $VBoxContainer/StartButton

var selected_pack: StarterPack = null

var cards: Array = []

@export var game_scene: PackedScene

func _ready():
	setup_buttons()
	start_button.disabled = true

func setup_buttons():
	for pack in starter_packs:
		var card = card_scene.instantiate()
		buttons_holder.add_child(card)
		
		card.setup(pack)
		
		if not pack.is_unlocked():
			card.disabled = true
			card.modulate = Color(0.4, 0.4, 0.4)
			if card.has_method("show_lock"):
				card.show_lock(true)
		else:
			card.pressed.connect(func():
				select_pack(pack, card)
			)
		
		cards.append(card)	
	
func select_pack(pack: StarterPack, selected_card):
	selected_pack = pack
	desc_label.text = pack.description
	start_button.disabled = false

	for c in cards:
		c.select_visual(c == selected_card)

func _on_StartButton_pressed():
	if selected_pack == null:
		return
	
	# 🔥 create game scene manually
	var game = game_scene.instantiate()
	
	# pass starter pack BEFORE scene starts
	game.selected_starter_pack = selected_pack
	
	get_tree().root.add_child(game)
	get_tree().current_scene.queue_free()
	get_tree().current_scene = game

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")
