extends Panel

@onready var icon = $Icon

@onready var type_label = $TypeLabel
@onready var damage_label = $DamageLabel
@onready var fire_rate_label = $FirerateLabel
@onready var dps_label = $DPSLabel
@onready var bullet_speed_label = $BulletSpeedLabel
@onready var energy_cost_label = $EnergyCostLabel

func _ready():
	add_to_group("weapon_info_panel")
	visible = false


func show_weapon(weapon_scene: PackedScene):
	if weapon_scene == null:
		hide_weapon()
		return

	var weapon = weapon_scene.instantiate()

	type_label.text = weapon.get_weapon_type_name()

	match weapon.rarity:
		Rarity.Type.COMMON:
			type_label.modulate = Color.WHITE

		Rarity.Type.RARE:
			type_label.modulate = Color.CORNFLOWER_BLUE

		Rarity.Type.LEGENDARY:
			type_label.modulate = Color.GOLD

		Rarity.Type.BOSS:
			type_label.modulate = Color.RED

	var damage = weapon.damage
	var fire_rate = weapon.fire_rate

	damage_label.text = "Damage: " + str(damage)

	fire_rate_label.text = "Fire Rate: " + str(snapped(fire_rate, 0.01))

	dps_label.text = "DPS: " + str(snapped(damage * fire_rate, 0.01))

	energy_cost_label.text = "Energy: " + str(weapon.energy_cost)

	if weapon.weapon_type == WeaponBase.WeaponType.SWORD:
		bullet_speed_label.visible = false
	else:
		bullet_speed_label.visible = true
		bullet_speed_label.text = "Bullet Speed: " + str(weapon.bullet_speed)

	icon.texture = weapon.display_texture

	weapon.queue_free()

	visible = true

func hide_weapon():
	visible = false
