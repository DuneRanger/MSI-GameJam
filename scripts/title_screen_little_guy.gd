extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func play_run_anim():
	$Sprite.play("run")
	
func play_walk_anim():
	$Sprite.play("walk")
	
func play_overclock_anim():
	$Sprite.play("overclock_idle")
