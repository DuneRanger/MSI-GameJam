extends Minigame

var half_period : float = 1.0

@export var full_bar : Control
@export var success_bar : ColorRect
@export var rod : ColorRect

var rod_tween : Tween

var global_top_bound : float
var global_bottom_bound : float

var full_distance : float 
const speed_per_pixel : float = 800

func _ready() -> void:	
	full_distance = full_bar.size.y - rod.size.y
	global_top_bound = success_bar.global_position.y
	global_bottom_bound = success_bar.global_position.y + success_bar.size.y
	
	var max_y : float = full_bar.size.y * (success_bar.anchor_top - rod.anchor_bottom)
	rod.position.y = randf_range(0.0, max_y)
	var remaining_distance : float = rod.position.y 
	rod_tween = create_tween()
	rod_tween.chain().tween_property(rod, "position", Vector2(0,0), remaining_distance / speed_per_pixel)
	rod_tween.set_ease(Tween.EASE_IN_OUT)
	rod_tween.tween_callback(link_remaining_tween)

func start_minigame() -> void:
	rod_tween.play()
	$Timer.start()

func link_remaining_tween() -> void:
	rod_tween = create_tween()
	rod_tween.tween_property(rod, "position", Vector2(0,full_distance), full_distance / speed_per_pixel)
	rod_tween.chain().tween_property(rod, "position", Vector2(0,0), full_distance / speed_per_pixel)
	rod_tween.set_ease(Tween.EASE_IN_OUT)
	rod_tween.set_loops()

func _on_start_button_down() -> void:
	start_minigame()

func _on_fish_button_down() -> void:
	var global_top_rod : float = rod.global_position.y
	var global_bottom_rod : float = rod.global_position.y + rod.size.y
	if (global_top_rod > global_top_bound) and (global_top_rod < global_bottom_bound):
		pass
	elif (global_bottom_rod > global_top_bound) and (global_bottom_rod < global_bottom_bound):
		pass
	else:
		minigame_failed.emit()
		return
	minigame_completed.emit()


func _on_timer_timeout() -> void:
	minigame_failed.emit()
