class_name Machine
extends Node2D

enum State { RUNNING, OVERHEATED, IN_MINIGAME, BROKEN }

@export var sprite: AnimatedSprite2D
@export var linked_minigame_scene : PackedScene
var linked_minigame : Minigame

# Heat parameters
@export var spike_chance_per_second: float = 0.05
@export var spike_multiplier: float = 1.2
@export var explosion_temperature: float = 250.0
@export var overheat_temperature: float = 100.0
@export var heat_rate: float = 5.0

# Minigame
var minigame_id: int = 1
@onready var interaction_area: Area2D = $InteractionArea

var state: State = State.RUNNING
var temperature: float = 0.0
var player_in_range: bool = false

var id: int = 0
static var next_id: int = 0

signal minigame_requested(machine: Machine, minigame_id: int)
var is_glowing: bool = false

func _init():
	id = next_id
	next_id += 1
	temperature = (randf() / 2) * overheat_temperature

func _ready() -> void:
	add_to_group("machines")
	enter_state(State.RUNNING)
	linked_minigame = linked_minigame_scene.instantiate() as Minigame

func turn_on_glow():
	is_glowing = true

func turn_off_glow():
	is_glowing = false

func _process(delta: float) -> void:
	process_state(delta)
	if is_glowing:
		sprite.modulate = Color(1.5, 1.4, 0.8)
		is_glowing = false
	else:
		sprite.modulate = Color(1, 1, 1)

func _on_interaction_area_body_entered(body: Node2D) -> void:
	print("Something entered")
	if body is Player:
		player_in_range = true
		body.add_nearby_machine(self)
		print("Player entered")

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_range = false
		body.remove_nearby_machine(self)
		print("Player exited")

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
			if temperature > overheat_temperature:
				change_state(State.OVERHEATED)
		State.OVERHEATED:
			update_temperature(delta)
			if temperature > explosion_temperature:
				change_state(State.BROKEN)
			pass
		State.IN_MINIGAME: pass
		State.BROKEN: pass

func update_temperature(delta: float) -> void:
	temperature += heat_rate * delta
	if (randf() < spike_chance_per_second * delta):
		temperature *= spike_multiplier

func interact() -> void:
	start_minigame()

func start_minigame() -> void:
	print("Starting minigame for machine ", id)
	minigame_requested.emit(self, minigame_id)
	change_state(State.IN_MINIGAME)

func on_minigame_success() -> void:
	temperature = 0
	print("Minigame success, temperature: ", temperature)
	change_state(State.RUNNING)
	
func on_minigame_failed() -> void:
	temperature *= spike_multiplier
	print("Minigame failed, temperature: ", temperature)
	# change to overheated, because minigames should only run when overheated
	# but for debugging, they run whenever
	change_state(State.OVERHEATED)
