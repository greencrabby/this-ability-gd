extends HBoxContainer

@onready var label = $Label

var run_manager

func _ready():
	await get_tree().process_frame
	run_manager = get_tree().get_first_node_in_group("run_manager")
	if run_manager == null:
		push_error("MoneyUI: RunManager not found!")
		return
	
	run_manager.money_changed.connect(update_ui)
	update_ui()

func update_ui():
	label.text = str(run_manager.money)
