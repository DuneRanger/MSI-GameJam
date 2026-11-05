extends Node

@export var minigame_scenes : Array[PackedScene]
var chosen_minigame : Minigame = null
var activated_machine: Machine = null

func _ready() -> void:
	for node in get_tree().get_nodes_in_group("machines"):
		var machine := node as Machine
		machine.minigame_requested.connect(_on_minigame_requested)

func _process(delta: float) -> void:
	$LabelStamina.text = "Stamina : " + str($Player.stamina)

func choose_minigame() -> Minigame:
	var chosen_scene = minigame_scenes.pick_random()
	var out = chosen_scene.instantiate()
	return out as Minigame

func _on_random_game_button() -> void:
	if chosen_minigame != null:
		print("Game is not null")
		return
	chosen_minigame = choose_minigame()
	link_chosen_minigame()

func _on_minigame_requested(machine: Machine, minigame_id: int) -> void:
	chosen_minigame = minigame_scenes[minigame_id].instantiate() as Minigame
	activated_machine = machine
	link_chosen_minigame()

func link_chosen_minigame() -> void:
	chosen_minigame.minigame_completed.connect(_on_minigame_success)
	chosen_minigame.minigame_failed.connect(_on_minigame_fail)
	$Control.add_child(chosen_minigame)
	chosen_minigame.start_minigame()

func _on_minigame_fail() -> void:
	$Background.color = Color.CRIMSON
	$MinigameLeaveTimer.start()
	activated_machine.on_minigame_failed()
	activated_machine = null

func _on_minigame_success() -> void:
	$Background.color = Color.WEB_GREEN
	$MinigameLeaveTimer.start()
	activated_machine.on_minigame_success()
	activated_machine = null

func _on_minigame_leave_timer_timeout() -> void:
	$Background.color = Color.SKY_BLUE
	$Control.remove_child(chosen_minigame)
	chosen_minigame.queue_free()
	chosen_minigame = null


func _on_wheel_button_button_down() -> void:
	if chosen_minigame != null:
		print("Game is not null")
		return
	chosen_minigame = minigame_scenes[1].instantiate()
	link_chosen_minigame()


func _on_color_button_button_down() -> void:
	if chosen_minigame != null:
		print("Game is not null")
		return
	chosen_minigame = minigame_scenes[0].instantiate()
	link_chosen_minigame()
