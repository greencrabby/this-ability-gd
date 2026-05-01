extends Area2D

@export var relic: RelicBase

@onready var sprite = $Sprite2D

func _ready():
	add_to_group("interactable")
	if relic and relic.icon:
		sprite.texture = relic.icon

func interact(player):
	player.interactables.erase(self)

	var run = get_tree().get_first_node_in_group("run_manager")
	if run:
		var success = run.add_relic(relic)

		if success:
			relic.on_pickup(player)

	queue_free()
