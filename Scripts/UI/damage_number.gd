extends Node2D

@onready var label = $Label

var velocity := Vector2(0, -40)
var lifetime := 0.6

func setup(value: float):
	label.text = str(int(value))

func _process(delta):
	position += velocity * delta
	lifetime -= delta
	
	modulate.a = lifetime / 0.6
	
	if lifetime <= 0:
		queue_free()
