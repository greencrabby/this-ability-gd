class_name StarterPack
extends Resource

@export var pack_name: String
@export var description: String

@export var starting_weapon: PackedScene
@export var starting_relics: Array[RelicBase] = []
@export var starting_money: int = 0

@export var icon: Texture2D

@export var unlocking_skill: SkillNode

func is_unlocked() -> bool:
	if unlocking_skill == null:
		return true
	return MetaManager.is_unlocked(unlocking_skill)
