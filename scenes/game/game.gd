extends Node

@export var levels: Array[PackedScene] = []
@onready var level_container = $LevelContainer
var current_level: Node = null
var current_difficulty : int = 0
var levels_finished : int = 0

@export var minigame_scenes : Array[PackedScene]
var chosen_minigame : Minigame = null
var activated_machine: Machine = null

@onready var minigame_failure_sound : AudioStream = load("res://assets/sfx/machines/failure.mp3")
@onready var minigame_success_sound : AudioStream = load("res://assets/sfx/machines/success.wav")
var minigame_result : bool = false

func _on_tilemap_machine_enter_tree(new_node : Node):
	if new_node is Machine:
		add_machine(new_node as Machine)

func add_machine(new_machine : Machine) -> void:
	new_machine.minigame_requested.connect(_on_minigame_requested)
	print("Added machine", new_machine)

func load_level() -> void:
	if current_level:
		levels_finished += 1
		current_level.queue_free()
		await current_level.tree_exited
	current_level = levels[levels_finished].instantiate()
	level_container.add_child(current_level)
	current_level.machine_layer.child_entered_tree.connect(add_machine)
	start_level()

func start_level() -> void:
	$LevelTimer.start()

func _on_level_timer_timeout() -> void:
	# trigger loss and Lucky dialogue
	print("Level timer ran out!!")
	load_level()

func _ready() -> void:
	load_level()

func _process(_delta: float) -> void:
	if current_level != null:
		$LabelStamina.text = "Stamina : " + str(current_level.player.stamina)
	$LevelTimerProgressBar.value = $LevelTimer.wait_time - $LevelTimer.time_left
	$LevelTimerProgressBar.max_value = $LevelTimer.wait_time

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
	current_level.player.player_state = Player.player_states.WALKING
