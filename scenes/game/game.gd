extends Node

@export var levels: Array[PackedScene] = []
@onready var level_container = $LevelContainer
var levels_by_difficulty = {}
var current_level: Node = null
var current_level_scene: PackedScene = null
var current_difficulty : int = 0
var levels_finished : int = 0
var level_finished : bool = false
var is_level_started : bool = false

static var played_tutorial : bool = false

@export var progress_timer_hud : TextureProgressBar
@export var lives_left_label : RichTextLabel
@export var level_num_label : RichTextLabel

@export var level_end_delay : float = 5
@export var level_start_delay : float = 5

var max_lives : int = 3
var lives : int = 0

@export var minigame_scenes : Array[PackedScene]
var chosen_minigame : Minigame = null
var activated_machine: Machine = null

@onready var minigame_failure_sound : AudioStream = load("res://assets/sfx/machines/failure.mp3")
@onready var minigame_success_sound : AudioStream = load("res://assets/sfx/machines/success.wav")
var minigame_result : bool = false

signal return_to_menu

func add_machine(new_machine : Machine) -> void:
	print("adding machine ", new_machine.id)
	new_machine.minigame_requested.connect(_on_minigame_requested)
	new_machine.machine_exploded.connect(_on_machine_exploded)
	if is_level_started:
		print("Level started")
		new_machine.start_machine()

func start_new_game() -> void:
	update_levels_finished(0)
	$CanvasLayer2/DialogueManager.playing_total_victory_screen = false
	current_difficulty = 0
	if (current_level != null):
		current_level.queue_free()
	current_level = null
	select_next_level()
	load_level()
	if !played_tutorial:
		$CanvasLayer2/DialogueManager.play_tutorial()
	else:
		start_level()

func select_next_level() -> void:
	if current_level != null:
		current_level.queue_free()
		await current_level.tree_exited
		const level_count_per_difficulty = 1
		if levels_finished % level_count_per_difficulty == 0:
			current_difficulty += 1
	print("Currently lev finished: ", levels_finished)
	
	# Sets the difficulty to either the next difficulty higher than `current_difficulty`, or max difficulty
	if current_difficulty not in levels_by_difficulty:
		var difficulties = levels_by_difficulty.keys() as Array[int]
		difficulties.sort()
		for diff in difficulties:
			var old_diff = current_difficulty
			current_difficulty = diff
			if diff > old_diff:
				break
	
	current_level_scene = levels_by_difficulty.get(current_difficulty).pick_random()

func load_level() -> void:
	if current_level != null:
		level_container.remove_child(current_level)
		#current_level.queue_free()
	current_level = current_level_scene.instantiate()
	level_container.add_child(current_level)
	
	current_level.machine_layer.child_entered_tree.connect(add_machine)
	current_level.player.set_physics_process(false)
 
func start_level() -> void:
	$HUD.visible = true
	update_lives(max_lives)
	level_finished = false
	$LevelTimer.start()
	current_level.player.set_physics_process(true)
	is_level_started = true
	print("Starting machines")
	current_level.start_level()
	MusicAndAmbiencePlayer.play_game_music()

func _on_level_timer_timeout() -> void:
	is_level_started = false
	level_finished = true
	force_end_current_minigame()
	$CanvasLayer2/DialogueManager.play_win_dialogue(level_end_delay)
	current_level.player.force_idle_anim()
	current_level.player.set_physics_process(false)
	await get_tree().create_timer(level_end_delay).timeout
	
	update_levels_finished(levels_finished + 1)
	print("Deciding", levels.size())
	if levels_finished >= levels.size():
		print("Total victory")
		$CanvasLayer2/DialogueManager.play_total_victory()
	else:
		print("NEXT LEVEL")
		select_next_level()
		load_level()
		start_level()

func _ready() -> void:
	current_difficulty = 999999
	for level in levels:
		var inst = level.instantiate()
		var d = inst.difficulty
		current_difficulty = min(current_difficulty, d)
		inst.free()
		levels_by_difficulty.get_or_add(d, []).append(level)
	
	for diff in levels_by_difficulty:
		print(diff)

func _process(_delta: float) -> void:
	progress_timer_hud.value = $LevelTimer.wait_time - $LevelTimer.time_left
	progress_timer_hud.max_value = $LevelTimer.wait_time

func _on_minigame_requested(machine: Machine) -> void:
	chosen_minigame = machine.linked_minigame_scene.instantiate() as Minigame
	activated_machine = machine
	link_chosen_minigame()
	
func _on_machine_exploded(_explode_machine: Machine) -> void:
	if level_finished: return
	update_lives(lives-1)
	if lives == 0:
		$HUD.visible = false
		level_finished = true
		is_level_started = false
		if current_level != null: #just to be sure idfk
			current_level.level_over()
		force_end_current_minigame()
		$CanvasLayer2/DialogueManager.play_lose_dialogue()

func force_end_current_minigame() -> void:
	if chosen_minigame != null:
		$HUD/MinigameHUD.remove_child(chosen_minigame)
		chosen_minigame.queue_free()
		chosen_minigame = null

func update_lives(new_value : int):
	lives = max(new_value, 0)
	lives_left_label.text = "[b]%dx[/b]" % lives
	
func update_levels_finished(new_value : int):
	print("Updating to", new_value)
	levels_finished = max(new_value, 0)
	level_num_label.text = "[b]Level: %d[/b]" % (levels_finished + 1)

func link_chosen_minigame() -> void:
	chosen_minigame.minigame_completed.connect(_on_minigame_success)
	chosen_minigame.minigame_failed.connect(_on_minigame_fail)
	$HUD/MinigameHUD.add_child(chosen_minigame)
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
	force_end_current_minigame()
	current_level.player.player_state = Player.player_states.WALKING

func _on_dialogue_manager_retry_round() -> void:
	load_level() 
	start_level()

func _on_dialogue_manager_total_victory() -> void:
	print("Yay, you won")
	return_to_menu.emit()

func _on_dialogue_manager_tutorial_over() -> void:
	played_tutorial = true
	start_level()
