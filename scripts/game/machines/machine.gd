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

signal minigame_requested(machine: Machine, minigame_id: int)
var is_glowing: bool = false

func _init():
	id = next_id
	next_id += 1

func _ready() -> void:
	add_to_group("machines")
	sprite.sprite_frames = machine_type.sprite_frames
	interaction_area.body_entered.connect(on_body_entered)
	interaction_area.body_exited.connect(on_body_exited)
	enter_state(State.RUNNING)

func turn_on_glow():
	is_glowing = true

func turn_off_glow():
	is_glowing = false

func get_sprite_rect() -> Rect2:
	var texture = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
	var size = texture.get_size() * sprite.scale
	var top_left := sprite.position + sprite.offset * sprite.scale
	if sprite.centered: top_left -= size / 2.0
	return Rect2(top_left, size)

func _process(delta: float) -> void:
	process_state(delta)
	if is_glowing:
		sprite.modulate = Color(1.5, 1.4, 0.8)
		is_glowing = false
	else:
		sprite.modulate = Color(1, 1, 1)

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
	minigame_requested.emit(self, 1)
	change_state(State.IN_MINIGAME)

func on_minigame_success() -> void:
	temperature = 0
	print("Minigame success, temperature: ", temperature)
	change_state(State.RUNNING)
	
func on_minigame_failed() -> void:
	temperature *= machine_type.spike_multiplier
	print("Minigame failed, temperature: ", temperature)
	# change to overheated, because minigames should only run when overheated
	# but for debugging, they run whenever
	change_state(State.OVERHEATED)
