@abstract class_name Minigame extends Control

signal minigame_completed
signal minigame_failed

@onready var failure_sound : AudioStream = load("res://assets/sfx/machines/failure.mp3")
@onready var success_sound : AudioStream = load("res://assets/sfx/machines/success.wav")

@abstract func start_minigame() -> void

func _process(_delta: float) -> void:
	$ProgressBar.value = $Timer.time_left
	$ProgressBar.max_value = $Timer.wait_time

func play_failure_sound() -> void:
	$AudioStreamPlayer.stream = failure_sound
	$AudioStreamPlayer.play()

func play_success_sound() -> void:
	$AudioStreamPlayer.stream = success_sound
	$AudioStreamPlayer.play()
