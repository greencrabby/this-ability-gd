extends Panel

@onready var icon = $Icon
@onready var name_label = $NameLabel
@onready var description_label = $DescriptionLabel

func _ready():
	add_to_group("relic_info_panel")
	visible = false

func show_relic(relic: RelicBase):
	if relic == null:
		hide_relic()
		return

	visible = true

	icon.texture = relic.icon
	name_label.text = relic.relic_name
	description_label.text = relic.description

	match relic.rarity:
		Rarity.Type.COMMON:
			name_label.modulate = Color.WHITE

		Rarity.Type.RARE:
			name_label.modulate = Color.CORNFLOWER_BLUE

		Rarity.Type.LEGENDARY:
			name_label.modulate = Color.RED

		Rarity.Type.BOSS:
			name_label.modulate = Color.GOLD

func hide_relic():
	visible = false
