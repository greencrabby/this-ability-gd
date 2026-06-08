extends Control

func _ready():
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = MouseFilter.MOUSE_FILTER_IGNORE

func _process(_delta):
	queue_redraw()

func _draw():
	var buttons_container = get_parent().get_node("ButtonsContainer")
	if not buttons_container: return
	
	var buttons = buttons_container.get_children()
	
	for node in buttons:
		if not node is Button or !("skill_data" in node) or node.skill_data == null:
			continue
			
		var target_skill = node.skill_data.prerequisite
		
		if target_skill:
			var parent_button = null
			for b in buttons:
				if "skill_data" in b and b.skill_data == target_skill:
					parent_button = b
					break
			
			if parent_button:
				var start = node.position + (node.size / 2)
				var end = parent_button.position + (parent_button.size / 2)
				
				var is_unlocked = MetaManager.is_unlocked(node.skill_data)
				var line_color = Color.GOLD if is_unlocked else Color(0.3, 0.3, 0.3, 0.6)
				
				draw_line(start, end, line_color, 4.0, true)
