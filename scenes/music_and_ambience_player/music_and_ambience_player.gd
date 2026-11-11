extends Node

@onready var game_music_stream = preload("res://assets/music/FactoryTheme.ogg")
@onready var idle_music_stream = preload("res://assets/music/IdleTheme.ogg")

func play_idle_music():
	$MusicPlayer.volume_db = 10
	$MusicPlayer.stream = idle_music_stream
	$MusicPlayer.play()

func play_game_music():
	$MusicPlayer.volume_db = 10
	$MusicPlayer.stream = game_music_stream
	$MusicPlayer.play()

func fade_out():
	$AnimationPlayer.play("Music_FadeOut")

func _on_button_pressed() -> void:
	play_game_music()


func _on_button_2_pressed() -> void:
	play_idle_music()


func _on_button_3_pressed() -> void:
	fade_out()
