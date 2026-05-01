extends Node

var meta_points: int = 0
var unlocked_skills: Dictionary = {}
var unlocked_resources: Array[SkillNode] = []

func add_points(amount):
	meta_points += amount
	print("MetaManager Points Updated: ", meta_points)

func is_unlocked(skill: SkillNode) -> bool:
	if skill == null: return true
	return unlocked_skills.get(skill.skill_name, false)

func unlock_skill(skill: SkillNode) -> bool:
	if is_unlocked(skill):
		return false
	
	if skill.prerequisite and not is_unlocked(skill.prerequisite):
		print("Missing prerequisite: ", skill.prerequisite.skill_name)
		return false

	if meta_points < skill.cost:
		print("Not enough points!")
		return false

	meta_points -= skill.cost
	unlocked_skills[skill.skill_name] = true
	unlocked_resources.append(skill)
	return true
