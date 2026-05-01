extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@export var textures: Array[Texture2D]  # 0,25,50,75,100

@onready var label = $Label

var run_manager

func _ready():
	run_manager = get_tree().get_first_node_in_group("run_manager")
	run_manager.health_changed.connect(update_ui)
	update_ui()

func update_ui():
	var hp = run_manager.health
	var max_hp = run_manager.max_health
	
	label.text = str(hp) + " / " + str(max_hp)
	
	var percent = float(hp) / max_hp
	
	var index = 0
	if percent <= 0.0:
		index = 0
	elif percent <= 0.25:
		index = 1
	elif percent <= 0.5:
		index = 2
	elif percent <= 0.75:
		index = 3
	else:
		index = 4
	
	sprite.texture = textures[index]
