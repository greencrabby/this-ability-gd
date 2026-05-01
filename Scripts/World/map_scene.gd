extends Node2D

func _ready() -> void:
	var generator = $MapGenerator
	generator.generate()
