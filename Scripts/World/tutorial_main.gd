extends Node2D

func _ready():
	$TutorialRunManager.start_run()
	$TutorialMapGenerator.generate()
	
