extends Node

@onready var audio_player = AudioStreamPlayer.new()

# Dictionary to hold your music tracks
var tracks = {
	"main_menu": preload("res://Assets/Audio/menutheme.wav"),
	"gameplay": preload("res://Assets/Audio/floor1theme.wav"),
	"boss": preload("res://Assets/Audio/boss1theme.wav")
}

var current_track = ""

func _ready():
	add_child(audio_player)
	audio_player.bus = "Music"
	audio_player.finished.connect(_on_audio_finished)

func play_track(track_key: String, fade_duration: float = 1.0):
	if current_track == track_key:
		return # Already playing
	
	if not tracks.has(track_key):
		push_error("Track not found: " + track_key)
		return

	var tween = create_tween()
	# Fade out
	tween.tween_property(audio_player, "volume_db", -80, fade_duration / 2)
	tween.tween_callback(func(): 
		audio_player.stream = tracks[track_key]
		audio_player.play()
		current_track = track_key
	)
	# Fade back in
	tween.tween_property(audio_player, "volume_db", 0, fade_duration / 2)

func _on_audio_finished():
	audio_player.play()
