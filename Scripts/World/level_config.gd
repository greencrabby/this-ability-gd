class_name LevelConfig
extends Resource

@export var floors: int = 4
@export var floor_configs: Array[FloorConfig]

# 🎮 stage pools
@export var combat_scenes: Array[PackedScene]
@export var encounter_scenes: Array[PackedScene]
@export var duel_scenes: Array[PackedScene]
@export var shop_scene: PackedScene
@export var boss_scene: PackedScene

@export var max_total_duels: int = 2
