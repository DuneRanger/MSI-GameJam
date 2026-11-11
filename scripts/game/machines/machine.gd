class_name Machine
extends Node2D

enum State { RUNNING, OVERHEATED, IN_MINIGAME, BROKEN }

@export var machine_sprite: AnimatedSprite2D
@export var linked_minigame_scene : PackedScene

# Heat parameters
@export var spike_chance_per_second: float = 0.05
@export var spike_multiplier: float = 1.2
@export var explosion_temperature: float = 250.0
@export var overheat_temperature: float = 100.0
@export var heat_rate: float = 3.0

# Minigame
@onready var interaction_area: Area2D = $InteractionArea

var state: State = State.RUNNING
var temperature: float = 0.0
var player_in_range: bool = false

var id: int = 0
static var next_id: int = 0

signal minigame_requested(machine: Machine)
signal machine_exploded(machine: Machine)
var is_glowing: bool = false

func _init():
	id = next_id
	next_id += 1
	temperature = (randf() * randf()) * overheat_temperature

func _ready() -> void:
	add_to_group("machines")
	enter_state(State.RUNNING)
	$ExplosionAnimationSprite.stop()
	$MachineLight.visible = false

func turn_on_glow():
	is_glowing = true
	machine_sprite.modulate = Color(1.5, 1.4, 0.8)
	
func turn_off_glow():
	is_glowing = false
	if state != State.BROKEN:
		machine_sprite.modulate = Color(1, 1, 1)

func play_explosion() -> void:
	var explosion_sprite: AnimatedSprite2D = $ExplosionAnimationSprite
	explosion_sprite.z_index = machine_sprite.z_index + 1
	explosion_sprite.play("explosion")
	$MachineSFX.pitch_scale = 1
	$MachineSFX.stream = load("res://assets/sfx/machines/machine_explosion.mp3")
	$MachineSFX.play()
	$MachineLight.visible = true
	$MachineLight.self_modulate = Color.ORANGE
	await  explosion_sprite.animation_finished
	$MachineLight.visible = false
	explosion_sprite.z_index = machine_sprite.z_index - 1
	explosion_sprite.scale = Vector2(1.4, 1.4)
	explosion_sprite.play("debris" + str(randi_range(1, 3)))

func _process(delta: float) -> void:
	process_state(delta)

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_range = true
		body.add_nearby_machine(self)

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_range = false
		body.remove_nearby_machine(self)

func change_state(new_state: State) -> void:
	if new_state == state: return
	var old = state
	exit_state(old)
	state = new_state
	enter_state(new_state)

func enter_state(new_state: State) -> void:
	match (new_state):
		State.RUNNING:
			machine_sprite.play("running")
			$MachineLight.visible = false
		State.OVERHEATED:
			machine_sprite.play("overheated")
			
			$MachineSFX.stream = load("res://assets/sfx/machines/sfx_overheat_start.mp3")
			$MachineSFX.pitch_scale = randf_range(0.8,1.2)
			$MachineSFX.play()
			$MachineLight.visible = true
			$MachineLight.self_modulate = Color.RED
		State.IN_MINIGAME:
			pass
		State.BROKEN:
			play_explosion()
			machine_exploded.emit(self)
			machine_sprite.play("broken")
			machine_sprite.modulate = Color(0.4, 0.4, 0.4, 1)

func exit_state(old_state: State) -> void:
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
	minigame_requested.emit(self)
	change_state(State.IN_MINIGAME)

func on_minigame_success() -> void:
	temperature = 0
	change_state(State.RUNNING)
	
func on_minigame_failed() -> void:
	temperature *= spike_multiplier + 0.1
	change_state(State.OVERHEATED)
