class_name Player extends CharacterBody2D

@export var timer_sfx_steps: Timer
@export var audio_player_steps: AudioStreamPlayer2D
@export var audio_player_sfx: AudioStreamPlayer2D

enum player_states {IN_MINIGAME, WALKING}
var player_state : player_states

var sfx_steps_normal_time = 0.33
var sfx_steps_overclock_time = 0.66
var sfx_steps_sprint_time = 0.2
var sfx_is_timer_playing = false

@export var movement_speed_default = 300
@export var movement_speed_sprint = 450
@export var movement_speed_exhausted = 100
var movement_speed = movement_speed_default
var character_direction : Vector2
var animation_name = "move"
#var overclock_timer_started = false
var is_overclocked = false ##if the player has depleted the stamina bar and is now recharging
var is_moving = false ## if the player is moving in any velocity (overclocked, normal and sprinting)
var is_sprinting = false ## if the player is sprinting (moving and holding shift and not overclocked)
var max_stamina = 100 ##the maximum amout of stamina the player can reach
var stamina = max_stamina ##the amount of stamina the player has right now



signal signal_player_stamina_change(stamina: int)

var nearby_machines: Array[Machine] = []

func _ready() -> void:
	add_to_group("player")
	player_state = player_states.WALKING

var glowing_machine: Machine = null
func _process(_delta) -> void:
	if glowing_machine != null: glowing_machine.turn_off_glow()
	if player_state == player_states.IN_MINIGAME: return
	
	nearby_machines.sort_custom(_sort_by_distance_desc)
	for machine in nearby_machines:
		if machine.state == Machine.State.OVERHEATED:
			machine.turn_on_glow()
			glowing_machine = machine
			if Input.is_action_just_pressed("interact"):
				machine.interact()
				player_state = player_states.IN_MINIGAME
			break

func _physics_process(delta: float) -> void:
	character_direction.x = Input.get_axis("move_left", "move_right")
	character_direction.y = Input.get_axis("move_up", "move_down")
	
	#horizontální flipování spritu
	if character_direction.x > 0:
		$PlayerSprite.flip_h = false
	elif character_direction.x < 0:
		$PlayerSprite.flip_h = true
	
	if is_overclocked == true:
		if stamina == max_stamina:
			recharge()
	
	#sprint handling
	if Input.is_action_pressed("sprint"):
		if is_moving == true:
			if is_overclocked == false:
				#the start of the sprint takes away more stamina
				#this is so the player wont just press shift repeatedly to try and outsmart the stamina system
				if is_sprinting == false:
					change_stamina(-10 * delta)
				
				if is_sprinting == false:
					audio_player_sfx.stream = load("res://assets/sfx/player/player_dash.mp3")
					audio_player_sfx.play()
				
				is_sprinting = true
				animation_name = "run"
				change_stamina(-1 * delta)
				movement_speed = movement_speed_sprint
				if stamina <= 0:
					overclock()
				#if overclock_timer_started == false:
					#overclock_timer_started = true
					#$OverclockTimer.start()
	if Input.is_action_just_released("sprint"):
		if is_overclocked == false:
			is_sprinting = false
			animation_name = "move"
			movement_speed = movement_speed_default
			#$OverclockTimer.stop()
			#overclock_timer_started = false
	
	if is_sprinting == false:
		if stamina != max_stamina:
			change_stamina(0.5 * delta)
	
	#nastavení animace a velocity
	if character_direction:
		
		#audio_player_steps.stream_paused = false
		
		if is_sprinting == true:
			play_step_sfx(sfx_steps_sprint_time)
		elif is_overclocked == true:
			play_step_sfx(sfx_steps_overclock_time)
		else:
			play_step_sfx(sfx_steps_normal_time)
			
		is_moving = true
		velocity = character_direction * movement_speed
		$PlayerSprite.animation = animation_name
	else:
		
		#audio_player_steps.stream_paused = true
		timer_sfx_steps.stop()
		sfx_is_timer_playing = false
		
		is_moving = false
		is_sprinting = false
		$OverclockTimer.stop()
		velocity = character_direction * movement_speed
		if is_overclocked == false:
			$PlayerSprite.animation = "idle"
		else:
			$PlayerSprite.animation = "overclocked_idle"

	move_and_slide()

func change_stamina(amount: float):
	stamina = clamp(stamina + amount * 60, 0, max_stamina)
	emit_signal("signal_player_stamina_change", stamina)

func overclock() -> void:
	audio_player_sfx.stream = load("res://assets/sfx/player/sfx_player_overclock.mp3")
	audio_player_sfx.play()
	
	is_sprinting = false
	is_overclocked = true
	#overclock_timer_started = false
	animation_name = "overclocked"
	movement_speed = movement_speed_exhausted
	
	
func recharge() -> void:
	audio_player_sfx.stream = load("res://assets/sfx/player/sfx_player_recharge.mp3")
	audio_player_sfx.play()
	is_overclocked = false
	animation_name = "move"
	movement_speed = movement_speed_default

func play_step_sfx(time_amount : float):
	if sfx_is_timer_playing == false:
		audio_player_steps.pitch_scale = randf_range(0.8, 1.2)
		audio_player_steps.play()
		sfx_is_timer_playing = true
		timer_sfx_steps.wait_time = time_amount
		timer_sfx_steps.start()

func _on_timer_sfx_steps_timeout() -> void:
	sfx_is_timer_playing = false
	audio_player_steps.play()
	timer_sfx_steps.stop()
	

#func _on_overclock_timer_timeout() -> void:
	#overclock()
	#$OverclockTimer.stop()
	#$RechargeTimer.start()

#func _on_recharge_timer_timeout() -> void:
	#is_overclocked = false
	#animation_name = "move"
	#movement_speed = movement_speed_default

func add_nearby_machine(machine: Machine) -> void:
	print("added machine ", machine.id)
	nearby_machines.append(machine)
	
func remove_nearby_machine(machine: Machine) -> void:
	print("removed machine ", machine.id)
	nearby_machines.erase(machine)

func _sort_by_distance_desc(a: Machine, b: Machine) -> bool:
	var pos = global_position
	return a.global_position.distance_squared_to(pos) < b.global_position.distance_squared_to(pos)
