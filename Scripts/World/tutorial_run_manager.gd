extends RunManager
class_name TutorialRunManager

func _ready():
	super._ready()

func start_run():
	run_started = true

func calculate_points() -> int:
	return 0

func on_run_failed():
	print("Tutorial failed")

	get_tree().reload_current_scene()

func on_run_success():
	print("Tutorial completed")

	MusicManager.play_track("main_menu", 1.0)
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func apply_tree_upgrades():
	pass
