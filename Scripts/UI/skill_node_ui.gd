extends Button

@export var skill_data: SkillNode

@onready var state_label = $Label 

func _ready():
	add_to_group("skill_ui_nodes")
	update_ui()

func _pressed():
	# Use the quiet check to see if it's even clickable
	if not can_purchase_quietly():
		if MetaManager.meta_points < skill_data.cost:
			print("Too poor! Need ", skill_data.cost)
		return
	
	if MetaManager.unlock_skill(skill_data):
		# We call the group FIRST so everyone updates, then ourselves
		get_tree().call_group("skill_ui_nodes", "update_ui")
	else:
		print("Cannot purchase: Check prerequisites or points.")

func update_ui():
	if not skill_data: return
	
	text = skill_data.skill_name
	
	# 1. Already Owned
	if MetaManager.is_unlocked(skill_data):
		modulate = Color.GOLD
		state_label.text = "OWNED"
		disabled = false 
		
	# 2. Prerequisites met AND can afford
	elif can_purchase_quietly():
		modulate = Color.WHITE
		state_label.text = str(skill_data.cost) + " pts"
		disabled = false
		
	# 3. Prerequisites met but TOO POOR
	elif is_prerequisite_met() and MetaManager.meta_points < skill_data.cost:
		modulate = Color.CRIMSON # Make it red so they know they need points
		state_label.text = str(skill_data.cost) + " pts"
		disabled = false # Keep it clickable so they can see the "Too Poor" print
		
	# 4. Prerequisites NOT met
	else:
		modulate = Color(0.3, 0.3, 0.3)
		state_label.text = "LOCKED"
		disabled = true

# Helper function to check ONLY prerequisites
func is_prerequisite_met() -> bool:
	if skill_data.prerequisite == null:
		return true
	return MetaManager.is_unlocked(skill_data.prerequisite)

func can_purchase_quietly() -> bool:
	# Check Ownership
	if MetaManager.is_unlocked(skill_data): 
		return false
	
	# Check Prerequisite
	if not is_prerequisite_met():
		return false
		
	# Check Cash
	if MetaManager.meta_points < skill_data.cost:
		return false
	
	return true
