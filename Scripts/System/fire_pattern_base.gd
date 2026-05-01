class_name FirePatternBase
extends Node

@export var fire_rate: float = 1.0
var cooldown: float = 0.0

func try_fire(shooter, target_position):
	if cooldown > 0:
		return
	
	fire(shooter, target_position)
	cooldown = 1.0 / fire_rate

func fire(shooter, target_position):
	pass

func _process(delta):
	if cooldown > 0:
		cooldown -= delta
