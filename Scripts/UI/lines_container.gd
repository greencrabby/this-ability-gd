extends Control

func _ready():
	# Make sure this node covers the area inside the ZoomContainer
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE

func _process(_delta):
	queue_redraw()

func _draw():
	# Get the sibling container that holds the buttons
	var buttons_container = get_parent().get_node("ButtonsContainer")
	if not buttons_container: return
	
	var buttons = buttons_container.get_children()
	
	for node in buttons:
		# Safety: Ensure it's a button and has the skill_data resource
		if not node is Button or !("skill_data" in node) or node.skill_data == null:
			continue
			
		# 🟢 REVERTED: Accessing 'prerequisite' (singular)
		var target_skill = node.skill_data.prerequisite
		
		if target_skill:
			# Find the physical button that owns the prerequisite skill
			var parent_button = null
			for b in buttons:
				if "skill_data" in b and b.skill_data == target_skill:
					parent_button = b
					break
			
			if parent_button:
				# Use local 'position' since they are siblings in the same ZoomContainer
				var start = node.position + (node.size / 2)
				var end = parent_button.position + (parent_button.size / 2)
				
				# Visual Feedback: Gold if unlocked, Grey if locked
				var is_unlocked = MetaManager.is_unlocked(node.skill_data)
				var line_color = Color.GOLD if is_unlocked else Color(0.3, 0.3, 0.3, 0.6)
				
				draw_line(start, end, line_color, 4.0, true)
