extends Node

@export var minigame_scenes : Array[PackedScene]
var chosen_minigame : Minigame = null
var activated_machine: Machine = null

var machine_idx : int
var machine_dict : Dictionary[int, Machine] = {}

@onready var minigame_failure_sound : AudioStream = load("res://assets/sfx/machines/failure.mp3")
@onready var minigame_success_sound : AudioStream = load("res://assets/sfx/machines/success.wav")
var minigame_result : bool = false

func _on_tilemap_machine_enter_tree(new_node : Node):
	if new_node is Machine:
		add_machine(new_node as Machine)

func add_machine(new_machine : Machine) -> void:
	new_machine.id = machine_idx
	machine_dict.set(machine_idx, new_machine)
	machine_idx += 1
	new_machine.minigame_requested.connect(_on_minigame_requested)
	print("Added machine", new_machine)

func _ready() -> void:
	machine_idx = 1
	var machine_layer : TileMapLayer = $YSortNode/Tilemap/TileMapMachineLayer
	machine_layer.child_entered_tree.connect(add_machine)
		

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

func _on_minigame_requested(machine: Machine) -> void:
	chosen_minigame = machine.linked_minigame_scene.instantiate() as Minigame
	activated_machine = machine
	link_chosen_minigame()

func link_chosen_minigame() -> void:
	chosen_minigame.minigame_completed.connect(_on_minigame_success)
	chosen_minigame.minigame_failed.connect(_on_minigame_fail)
	$MinigameHUD.add_child(chosen_minigame)
	minigame_result = false
	chosen_minigame.start_minigame()

func play_minigame_failure_sound() -> void:
	$MinigameResultPlayer.stream = minigame_failure_sound
	$MinigameResultPlayer.play()

func play_minigame_success_sound() -> void:
	$MinigameResultPlayer.stream = minigame_success_sound
	$MinigameResultPlayer.play()

func _on_minigame_fail() -> void:
	if minigame_result: return
	$MinigameLeaveTimer.start()
	minigame_result = true
	play_minigame_failure_sound()
	if activated_machine != null:
		activated_machine.on_minigame_failed()
		activated_machine = null

func _on_minigame_success() -> void:
	if minigame_result: return
	$MinigameLeaveTimer.start()
	minigame_result = true
	play_minigame_success_sound()
	if activated_machine != null:
		activated_machine.on_minigame_success()
		activated_machine = null

func _on_minigame_leave_timer_timeout() -> void:
	$MinigameHUD.remove_child(chosen_minigame)
	chosen_minigame.queue_free()
	chosen_minigame = null
	$YSortNode/Player.player_state = Player.player_states.WALKING

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
