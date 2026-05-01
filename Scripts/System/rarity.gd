# rarity.gd
class_name Rarity

enum Type {
	COMMON,
	RARE,
	LEGENDARY,
	BOSS
}

static func get_color(rarity: int) -> Color:
	match rarity:
		Type.COMMON: return Color.GRAY
		Type.RARE: return Color.DEEP_SKY_BLUE
		Type.LEGENDARY: return Color.MEDIUM_PURPLE
		Type.BOSS: return Color.GOLD
	return Color.WHITE
