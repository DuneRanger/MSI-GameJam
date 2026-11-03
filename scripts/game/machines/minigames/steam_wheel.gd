extends Minigame

const max_angle_speed_per_second : float = PI

var minigame_over : bool = false

var is_wheel_selected : bool = false
var last_selected_mouse_pos : Vector2
var acceleration : float

var total_rotation : float = 0.0
var total_rotation_needed : float = 2 * PI

var center : Vector2 

func _ready() -> void:
	center = $WheelInputArea/SteamWheel.global_position - $WheelInputArea/SteamWheel.size / 2
	$Timer.start()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		is_wheel_selected = true
	elif Input.is_action_just_released("left_click"):
		is_wheel_selected = false
	if not is_wheel_selected or minigame_over:
		return
	
	var current_wheel_rotation : float = get_current_wheel_rotation(delta)
	total_rotation = clampf(total_rotation + current_wheel_rotation, 0, total_rotation_needed)
	$WheelInputArea/SteamWheel.rotation = total_rotation
	
	if total_rotation >= total_rotation_needed:
		$Label.text = "Wheel over"
		minigame_over = true
		minigame_completed.emit()

func get_current_wheel_rotation(delta : float) -> float:
	var current_position : Vector2 = get_global_mouse_position() - center
	var this_angle : float = last_selected_mouse_pos.angle_to(current_position)
	last_selected_mouse_pos = current_position
	var current_max_angle : float = max_angle_speed_per_second * delta
	return clampf(this_angle, 0, current_max_angle)

func _on_timer_timeout() -> void:
	if total_rotation < total_rotation_needed:
		$Label.text = "Wheel failed"
		minigame_failed.emit()
		minigame_over = true
