extends Node

@onready var audio_player = AudioStreamPlayer.new()

var tracks = {
	"main_menu": preload("res://Assets/Audio/menutheme.wav"),
	"gameplay": preload("res://Assets/Audio/floor1theme.wav"),
	"boss1": preload("res://Assets/Audio/boss1theme.wav"),
	"boss2": preload("res://Assets/Audio/boss2theme.wav")
}

var current_track = ""

func _ready():
	add_child(audio_player)
	audio_player.bus = "Music"
	audio_player.finished.connect(_on_audio_finished)

func play_track(track_key: String, fade_duration: float = 1.0):
	if current_track == track_key:
		return
	
	if not tracks.has(track_key):
		push_error("Track not found: " + track_key)
		return

	var tween = create_tween()
	tween.tween_property(audio_player, "volume_db", -80, fade_duration / 2)
	tween.tween_callback(func(): 
		audio_player.stream = tracks[track_key]
		audio_player.play()
		current_track = track_key
	)
	tween.tween_property(audio_player, "volume_db", 0, fade_duration / 2)

func _on_audio_finished():
	audio_player.play()
