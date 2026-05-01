extends Control

@onready var points_label = $Header/VBoxContainer/PointsLabel

func _ready():
	update_points_display()

func update_points_display():
	points_label.text = "Available Points: " + str(MetaManager.meta_points)

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")
