extends Minigame

var button_count : int
@export var button_scene : PackedScene
var button_array : Array[Button] = []

@export var different_button_color : Color

var different_button : Button

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
	$Timer.start()
	different_button = button_array.pick_random()
	var new_style_box : StyleBoxFlat = StyleBoxFlat.new()
	new_style_box.copy_from_resource(different_button.get_theme_stylebox("normal") as StyleBoxFlat)
	new_style_box.bg_color = different_button_color
	different_button.add_theme_stylebox_override("normal", new_style_box)
	different_button.button_down.disconnect(_on_other_button_press)
	different_button.button_down.connect(_on_different_button_press)

func _on_different_button_press() -> void:
	minigame_completed.emit()

func _on_timer_timeout() -> void:
	minigame_failed.emit()

func _on_other_button_press() -> void:
	minigame_failed.emit()
