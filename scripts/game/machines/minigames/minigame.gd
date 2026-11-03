@abstract class_name Minigame extends Control

signal minigame_completed
signal minigame_failed

@abstract func start_minigame() -> void

func _process(_delta: float) -> void:
	$ProgressBar.value = $Timer.time_left
	$ProgressBar.max_value = $Timer.wait_time
