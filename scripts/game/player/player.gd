extends CharacterBody2D


@export var movement_speed_default = 300
@export var movement_speed_sprint = 450
@export var movement_speed_exhausted = 100
var movement_speed = movement_speed_default
var character_direction : Vector2
var animation_name = "move"
var overclocked = false
var overclock_timer_started = false

var nearby_machines: Array[Machine] = []

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:
	character_direction.x = Input.get_axis("move_left", "move_right")
	character_direction.y = Input.get_axis("move_up", "move_down")
	
	#horizontální flipování spritu
	if character_direction.x > 0:
		$PlayerSprite.flip_h = false
	elif character_direction.x < 0:
		$PlayerSprite.flip_h = true
	
	#sprint handling
	if Input.is_action_pressed("sprint"):
		if overclocked == false:
			animation_name = "run"
			movement_speed = movement_speed_sprint
			if overclock_timer_started == false:
				overclock_timer_started = true
				$OverclockTimer.start()
	if Input.is_action_just_released("sprint"):
		if overclocked == false:
			animation_name = "move"
			movement_speed = movement_speed_default
			$OverclockTimer.stop()
			overclock_timer_started = false
	
	#nastavení animace a velocity
	if character_direction:
		velocity = character_direction * movement_speed
		$PlayerSprite.animation = animation_name
	else:
		velocity = character_direction * movement_speed
		if overclocked == false:
			$PlayerSprite.animation = "idle"
		else:
			$PlayerSprite.animation = "overclocked_idle"

	move_and_slide()
	
	nearby_machines.sort_custom(_sort_by_distance_desc)
	if Input.is_action_just_pressed("interact"):
		for machine in nearby_machines:
			#if machine.state == Machine.State.OVERHEATED:
			machine.interact()

func _on_overclock_timer_timeout() -> void:
	overclocked = true
	overclock_timer_started = false
	animation_name = "overclocked"
	movement_speed = movement_speed_exhausted
	$OverclockTimer.stop()
	$RechargeTimer.start()

func _on_recharge_timer_timeout() -> void:
	overclocked = false
	animation_name = "move"
	movement_speed = movement_speed_default

func add_nearby_machine(machine: Machine) -> void:
	print("added machine ", machine.id)
	nearby_machines.append(machine)
	
func remove_nearby_machine(machine: Machine) -> void:
	print("removed machine ", machine.id)
	nearby_machines.erase(machine)

func _sort_by_distance_desc(a: Machine, b: Machine) -> bool:
	var pos := global_position
	return a.global_position.distance_squared_to(pos) < b.global_position.distance_squared_to(pos)
