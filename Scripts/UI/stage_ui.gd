extends Control

@onready var enemy_label = $EnemyCounter
@onready var clear_text = $ClearText
@onready var exit_hint = $ExitHint

var controller

func _ready():
	controller = get_parent().get_node("StageController")

	clear_text.visible = false
	exit_hint.visible = false

func _process(delta):
	if controller:
		enemy_label.text = "Enemies: %d" % controller.enemies_alive

		if controller.cleared:
			clear_text.visible = true
			exit_hint.visible = true
