class_name EndScreen
extends Control

@onready var points_label = $VBoxContainer/PointsLabel
static var points_to_display: int = 0

func _ready():
	points_label.text = "Points Earned: " + str(points_to_display)

func _on_continue():
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")
