extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@export var textures: Array[Texture2D]

@onready var label = $Label

var run_manager

func _ready():
	run_manager = get_tree().get_first_node_in_group("run_manager")
	run_manager.energy_changed.connect(update_ui)
	update_ui()

func update_ui():
	var e = run_manager.energy
	var max_e = run_manager.max_energy
	
	label.text = str(int(e)) + " / " + str(int(max_e))
	
	var percent = e / max_e
	
	var index = clamp(int(percent * 4), 0, 4)
	sprite.texture = textures[index]
