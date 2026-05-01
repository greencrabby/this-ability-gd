extends Button

@onready var pack_icon = $TextureRect
@onready var label = $Label

var pack: StarterPack

func _ready():
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_exit)

func _on_hover():
	scale = Vector2(1.1, 1.1)

func _on_exit():
	scale = Vector2(1, 1)

func setup(p: StarterPack):
	pack = p
	label.text = p.pack_name
	pack_icon.texture = p.icon   # 👈 you'll add this

func select_visual(selected: bool):
	if selected:
		modulate = Color(0.5, 1, 0.5) # green highlight
	else:
		modulate = Color(1, 1, 1)
