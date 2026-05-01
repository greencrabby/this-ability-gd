class_name RelicBase
extends Resource

@export var relic_name: String
@export var description: String

# optional restrictions

@export var rarity: Rarity.Type = Rarity.Type.COMMON

@export var icon: Texture2D


# =========================
# 📦 PICKUP
# =========================
func on_pickup(player):
	pass

# =========================
# 🔁 RUNTIME (every frame)
# =========================
func on_update(player, delta):
	pass

# =========================
# 🎯 COMBAT MODIFIERS
# =========================
func modify_damage(base_damage, weapon, player):
	return base_damage

func modify_fire_rate(base_rate, weapon, player):
	return base_rate

func modify_energy_cost(base_cost, weapon, player):
	return base_cost

# =========================
# 💰 ECONOMY
# =========================
func modify_currency_gain(amount, player):
	return amount

# =========================
# 🧱 PERMANENT STATS (RunManager)
# =========================
func modify_max_health(base_value, player):
	return base_value

func modify_max_energy(base_value, player):
	return base_value

func modify_energy_regen(base_value, player):
	return base_value

# =========================
# 🏃 MOVEMENT STATS
# =========================
func modify_acceleration(base_value, player):
	return base_value

func modify_max_speed(base_value, player):
	return base_value

func modify_brake_force(base_value, player):
	return base_value

# =========================
# 🔫 BULLETS (already used)
# =========================
func modify_bullet_speed(base_speed, bullet, shooter):
	return base_speed

func modify_incoming_bullet_speed(base_speed, bullet, player):
	return base_speed
