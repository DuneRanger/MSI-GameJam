extends Minigame

var button_count : int
@export var button_scene : PackedScene
var button_array : Array[Button] = []


@export var wrong_button_theme : StyleBoxFlat

var different_button : Button
var different_button_found : bool

func _ready() -> void:
	button_count = $GridContainer.columns * $GridContainer.columns
	print(button_count)
	for i in button_count:
		var new_button : Button = button_scene.instantiate()
		$GridContainer.add_child(new_button)
		new_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		new_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
		new_button.button_down.connect(_on_other_button_press)
		button_array.push_back(new_button)

func start_minigame() -> void:
	different_button_found = false
	$Timer.start()
	different_button = button_array.pick_random()
	different_button.add_theme_stylebox_override("normal", wrong_button_theme)
	different_button.button_down.disconnect(_on_other_button_press)
	different_button.button_down.connect(_on_different_button_press)

func _on_different_button_press() -> void:
	play_success_sound()
	different_button_found = true
	minigame_completed.emit()

func _on_timer_timeout() -> void:
	if !different_button_found:
		minigame_failed.emit()

func _on_other_button_press() -> void:
	play_failure_sound()
