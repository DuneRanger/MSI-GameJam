class_name Machine
extends Node2D

enum State { RUNNING, OVERHEATED, IN_MINIGAME, BROKEN }

@export var machine_type: MachineType

var state: State = State.RUNNING
var temperature: float = 0.0
var player_in_range: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_area: Area2D = $InteractionArea

var id: int = 0
static var next_id: int = 0

var x = 0
var y = 0

func _init(pos_x = 0, pos_y = 0):
	x = pos_x
	y = pos_y
	id = next_id
	next_id += 1

func _ready() -> void:
	sprite.sprite_frames = machine_type.sprite_frames
	interaction_area.body_entered.connect(on_body_entered)
	interaction_area.body_exited.connect(on_body_exited)

func _process(delta: float) -> void:
	process_state(delta)

func on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		body.add_nearby_machine(self)

func on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		body.remove_nearby_machine(self)

func change_state(new_state: State) -> void:
	if new_state == state: return
	var old = state
	exit_state(old)
	state = new_state
	enter_state(new_state)

func enter_state(new_state: State) -> void:
	print("Machine ", id, " entered state ", str(new_state))
	match (new_state):
		State.RUNNING:
			sprite.play("running")
		State.OVERHEATED:
			sprite.play("overheated")
		State.IN_MINIGAME:
			# Freeze all machines?, or just don't update this machine?
			pass
		State.BROKEN:
			sprite.play("broken")

func exit_state(old_state: State) -> void:
	print("Machine ", id, " exited state ", str(old_state))
	match (old_state):
		State.RUNNING: pass
		State.OVERHEATED: pass
		State.IN_MINIGAME: pass
		State.BROKEN: pass

func process_state(delta: float) -> void:
	match (state):
		State.RUNNING:
			update_temperature(delta)
			if temperature > machine_type.overheat_temperature:
				change_state(State.OVERHEATED)
		State.OVERHEATED:
			update_temperature(delta)
			if temperature > machine_type.explosion_temperature:
				change_state(State.BROKEN)
			pass
		State.IN_MINIGAME: pass
		State.BROKEN: pass

func update_temperature(delta: float) -> void:
	temperature += machine_type.heat_rate * delta
	if (randf() < machine_type.spike_chance_per_second * delta):
		temperature *= machine_type.spike_multiplier

func interact() -> void:
	#if not player_in_range or state != State.OVERHEATED:
		#return
	start_minigame()

var minigame: Minigame
func start_minigame() -> void:
	print("Starting minigame for machine ", id)
	minigame = machine_type.minigame_scene.instantiate() as Minigame
	minigame.minigame_completed.connect(on_minigame_success)
	minigame.minigame_failed.connect(on_minigame_failed)
	add_child(minigame)
	minigame.start_minigame()
	
	change_state(State.IN_MINIGAME)

func on_minigame_success() -> void:
	print("Minigame success")
	temperature = 0
	remove_child(minigame)
	change_state(State.RUNNING)
	
func on_minigame_failed() -> void:
	print("Minigame failed")
	temperature *= machine_type.spike_multiplier
	remove_child(minigame)
	change_state(State.OVERHEATED)
