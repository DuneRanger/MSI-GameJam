extends Control

#@onready var text_animation_player = $TextScrollAnimationPlayer

@onready var full_animation_player = $FullAnimationPlayer
@onready var character_portrait = $Portrait/CharacterPortrait
@onready var text_label = $Textbox/TextLabel
var is_displaying_dialogue = false
var dialogue_source
var dialogue_text
var dialogue_portrait : portraits
var is_loaded_dialogue_continuous = false
var i : int = 0 
var is_defeated = false
var is_end_of_level = false

var playing_total_victory_screen : bool = false
var playing_tutorial : bool = false

signal retry_round
signal total_victory
signal tutorial_over

var tutorial_lines = [
	[portraits.greeting, "Oh, hello little robot person"],
	[portraits.explaining, "You're like the 57th model they sent here so i'll make it quick"],
	#[portraits.smiling, "My names is Lucky by the way"],
	#[portraits.smiling2, "Because its lucky to keep me around,"],
	#[portraits.grumpy, "...or something..."],
	#[portraits.explaining, "I'm your manager and we're in a factory"],
	#[portraits.weird, "Don't really know what we're producing, actually..."],
	#[portraits.annoyed, "But that doesn't matter, what matters is that we're producing A LOT of things and stuff"],
	#[portraits.explaining, "As a result, all of our machines are OVERCLOCKED and running at full power"],
	#[portraits.grumpy, "...and they're overheating"],
	#[portraits.explaining, "And your job, my friend, is to keep them cool and keep them from exploding"],
	#[portraits.button_show, "See this button?"],
	#[portraits.button_laughing, "It's my favourite part of this job!"],
	#[portraits.button_grumpy, "If you let 3 machines overheat and explode..."],
	#[portraits.button_press_laughing, "Then I'll explode you by pressing this!"],
	#[portraits.excited, "Yeah that's about it"],
	#[portraits.explaining, "Be careful when running, so you yourself wont overheat"],
	#[portraits.grumpy, "My boss also said that I was supposed to tell you... what was it?"],
	#[portraits.explaining, "WASD to move, E to interact, SHIFT to run, mouse to solve puzzles"],
	#[portraits.grumpy, "Whatever that means..."],
	#[portraits.greeting, "Ok now go do your job robot person"],
]

var defeat_lines = [
	[portraits.button_show, "Hey I wonder what's this button do?"],
	[portraits.sad, "Man... my boss is gonna fire me"],
	[portraits.grumpy, "Well, let's hope the next model will be better"],
	[portraits.button_laughing, "Oooh its my favourite part!"],
	[portraits.annoyed, "Why does this keep happening!?"],
	[portraits.explaining, "You'd think that the newer models would be improved"],
	[portraits.weird, "I'm tired"],
	[portraits.button_grumpy, "I'm sorry I have to do this to you"],
	[portraits.explaining, "You know you're supposed to cool down the machines?"],
	[portraits.button_show, "I'd say I'm sorry, but i like blowing stuff up"],
	[portraits.button_laughing, "Yaaay, fireworks!"],
	[portraits.annoyed, "How's this model even worse than the last one!?"],
]

#jo je to kokotsky ale ržd hubu
var button_press_face = [
	[portraits.button_press, ""],
	[portraits.button_press, ""],
	[portraits.button_press, ""],
	[portraits.button_press_laughing, ""],
]

var victory_lines = [
	[portraits.grumpy, "Good job. I guess..."],
	[portraits.explaining, "Nice, you didn't explode everything"],
	[portraits.smiling2, "Oh, what? I didn't expect you to succeed"],
	[portraits.excited, "Oh yes! I can go home now!"],
	[portraits.smiling, "You did well!"],
	[portraits.excited, "Good job!"],
	[portraits.weird, "Oh, you did it? Great. Now I own that guy 5 bucks"],
	[portraits.sad, "Noo, I really wanted to press the button today..."],
]

var total_victory_lines = [	
	[portraits.weird, "You did it all??"],
	[portraits.weird, "This vexes me"],
	[portraits.weird, "Here, go to the main menu"],
]

var active_text_lines

enum portraits {
	annoyed,
	button_grumpy,
	button_laughing,
	button_press,
	button_press_laughing,
	button_show,
	excited,
	explaining,
	greeting,
	grumpy,
	sad,
	smiling,
	smiling2,
	weird
	}

func _process(_delta: float) -> void:
	if is_displaying_dialogue == true:
		if Input.is_action_just_pressed("dialogue_skip"):
			if i != active_text_lines.size() - 1 and is_loaded_dialogue_continuous == true:
				if $TextScrollTimer.is_stopped():
					i += 1
					dialogue_text = active_text_lines[i][1]
					dialogue_portrait = active_text_lines[i][0]
					display_dialogue(dialogue_portrait ,dialogue_text)
			else:
				if is_end_of_level == true:
					pass
				elif is_defeated == true:
					play_random_dialogue(button_press_face)
					$DeathTimer.start()
					$AudioPlayer.stream = load("res://assets/sfx/button-press-382713.mp3")
					$AudioPlayer.play()
				elif playing_total_victory_screen == true:
					total_victory.emit()
					print("You totally won")
					$FullAnimationPlayer.play("dialogue_system_hide")
					is_end_of_level = false
					is_displaying_dialogue = false
				elif playing_tutorial == true:
					tutorial_over.emit()
					print("Tutorial is over")
					$FullAnimationPlayer.play("dialogue_system_hide")
					is_end_of_level = false
					is_displaying_dialogue = false
				else:
					if $TextScrollTimer.is_stopped():
						text_label.text = ""
						full_animation_player.play("dialogue_system_hide")
						is_displaying_dialogue = false
						
	
	if Input.is_key_pressed(KEY_R):
		$dieButton.visible = true
		$TestButton.visible = true
		$winButton.visible = true

func play_tutorial():
	i = 0
	is_loaded_dialogue_continuous = true
	playing_tutorial = true
	active_text_lines = tutorial_lines
	dialogue_text = active_text_lines[i][1]
	dialogue_portrait = active_text_lines[i][0]
	display_dialogue(dialogue_portrait, dialogue_text)

func play_total_victory():
	i = 0
	is_loaded_dialogue_continuous = true
	playing_total_victory_screen = true
	active_text_lines = total_victory_lines
	dialogue_text = active_text_lines[i][1]
	dialogue_portrait = active_text_lines[i][0]
	display_dialogue(dialogue_portrait, dialogue_text)

func play_random_dialogue(dialogue_array):
	is_loaded_dialogue_continuous = false
	i = randi_range(0, dialogue_array.size() - 1)
	dialogue_text = dialogue_array[i][1]
	dialogue_portrait = dialogue_array[i][0]
	display_dialogue(dialogue_portrait, dialogue_text)

func display_dialogue(portrait: portraits, dialogue : String):
	$AudioPlayer.stop()
	if is_displaying_dialogue == false:
		is_displaying_dialogue = true
		full_animation_player.play("dialogue_system_show")
	
	match is_end_of_level:
		true:
			$Textbox/Tip.text = ""
		false:
			$Textbox/Tip.text = "Press SPACE"
	
	$PortraitAnimationPlayer.play("portrait_wobble")
	load_portrait(portrait)
	text_label.text = dialogue
	
	play_speech_sfx()
	
	var t : Tween = get_tree().create_tween()
	$Textbox/TextLabel.visible_ratio = 0.0
	t.bind_node($Textbox/TextLabel)
	t.tween_property($Textbox/TextLabel, "visible_ratio", 1.0, 0.03 * dialogue.length())
	$TextScrollTimer.wait_time = 0.03 * dialogue.length() if dialogue.length() > 0 else 1.0
	$TextScrollTimer.start()
	
	#text_animation_player.play("text_scroll")


func load_portrait(action: portraits):
	match action:
		portraits.annoyed:
			character_portrait.texture = load("res://assets/game/lucky/dialog_actions/lucky_portrait_annoyed.png")
		portraits.button_grumpy:
			character_portrait.texture = load("res://assets/game/lucky/dialog_actions/lucky_portrait_button_grumpy.png")
		portraits.button_laughing:
			character_portrait.texture = load("res://assets/game/lucky/dialog_actions/lucky_portrait_button_laughing.png")
		portraits.button_press:
			character_portrait.texture = load("res://assets/game/lucky/dialog_actions/lucky_portrait_button_press.png")
		portraits.button_press_laughing:
			character_portrait.texture = load("res://assets/game/lucky/dialog_actions/lucky_portrait_button_press_laughing.png")
		portraits.button_show:
			character_portrait.texture = load("res://assets/game/lucky/dialog_actions/lucky_portrait_button_show.png")
		portraits.excited:
			character_portrait.texture = load("res://assets/game/lucky/dialog_actions/lucky_portrait_excited.png")
		portraits.explaining:
			character_portrait.texture = load("res://assets/game/lucky/dialog_actions/lucky_portrait_explaining.png")
		portraits.greeting:
			character_portrait.texture = load("res://assets/game/lucky/dialog_actions/lucky_portrait_greeting.png")
		portraits.grumpy:
			character_portrait.texture = load("res://assets/game/lucky/dialog_actions/lucky_portrait_grumpy.png")
		portraits.sad:
			character_portrait.texture = load("res://assets/game/lucky/dialog_actions/lucky_portrait_sad.png")
		portraits.smiling2:
			character_portrait.texture = load("res://assets/game/lucky/dialog_actions/lucky_portrait_smiling2.png")
		portraits.smiling:
			character_portrait.texture = load("res://assets/game/lucky/dialog_actions/lucky_portrait_smiling.png")
		portraits.weird:
			character_portrait.texture = load("res://assets/game/lucky/dialog_actions/lucky_portrait_weird.png")
		

func play_speech_sfx():
	$AudioPlayer.pitch_scale = randf_range(0.8, 1.2)
	if $AudioPlayer.playing != true:
		$AudioPlayer.stream = load("res://assets/sfx/sfx_speech.mp3")
		$AudioPlayer.play()


func play_lose_dialogue(): ##plays random dialogue if player loses and blows up the screen
	play_random_dialogue(defeat_lines)
	is_defeated = true

func play_win_dialogue(level_end_delay : float): ##plays random dialogue if player wins and automatically disappears
	is_end_of_level = true
	play_random_dialogue(victory_lines)
	await get_tree().create_timer(level_end_delay - 1).timeout
	$FullAnimationPlayer.play("dialogue_system_hide")
	is_end_of_level = false
	is_displaying_dialogue = false

func _on_test_button_button_down() -> void:
	play_tutorial()
	$TestButton.visible = false

func _on_die_button_button_down() -> void:
	play_lose_dialogue()
	$dieButton.visible = false


func _on_win_button_button_down() -> void:
	play_win_dialogue(5)
	$winButton.visible = false

func _on_text_scroll_timer_timeout() -> void:
	$TextScrollTimer.stop()
	$AudioPlayer.stop()


func _on_death_timer_timeout() -> void:
	$AudioPlayer.stop()
	$AudioPlayer.stream = load("res://assets/sfx/explosion.mp3")
	$AudioPlayer.play()
	$DeathTimer.stop()
	is_defeated = false
	full_animation_player.play("explosion")
	is_displaying_dialogue = false
	print("lucky pressed the button")

func _on_full_animation_player_animation_finished(anim_name: StringName) -> void:
	if (anim_name == "explosion"):
		retry_round.emit()
	print("animation : %s ended" % anim_name)
