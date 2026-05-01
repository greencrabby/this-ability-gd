class_name SkillNode
extends Resource

@export var skill_name: String
@export var cost: int = 1

@export var prerequisite: SkillNode
@export var associated_relic: RelicBase

func apply(run_manager):
	pass
