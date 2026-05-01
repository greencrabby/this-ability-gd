extends Control

func _ready():
	MusicManager.play_track("main_menu")

func _on_start_pressed():
	get_tree().change_scene_to_file("res://Scenes/UI/StarterSelect.tscn")

func _on_settings_pressed():
	get_tree().change_scene_to_file("res://Scenes/UI/SkillTree.tscn")
