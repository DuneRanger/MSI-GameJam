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

var tutorial_lines = [
	[portraits.happy, "Hello"],
	[portraits.angry, "grrrr im angry now"],
	[portraits.angry, "grr im still sooooooooooooooooooooooooooooooooooooooooooooo angry"],
	[portraits.happy, "Goodbye"]
]

var defeat_lines = [
	[portraits.angry, "Aww that sucks"],
	[portraits.angry, "Too bad"],
	[portraits.angry, "Come on, now i'll have to clean this up"]
]

var victory_lines = [
	[portraits.happy, "Good job. I guess..."],
	[portraits.happy, "Nice, you didn't explode everything"],
	[portraits.happy, "Oh, what? The shift is over already?"]
]

var active_text_lines

enum portraits {happy, angry}

func _process(delta: float) -> void:
	if is_displaying_dialogue == true:
		if Input.is_action_just_pressed("dialogue_skip"):
			if i != active_text_lines.size() - 1 and is_loaded_dialogue_continuous == true:
				if $TextScrollTimer.is_stopped():
					i += 1
					dialogue_text = active_text_lines[i][1]
					dialogue_portrait = active_text_lines[i][0]
					display_dialogue(dialogue_portrait ,dialogue_text)
			else:
				if $TextScrollTimer.is_stopped():
					print("konec")
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
	dialogue_text = tutorial_lines[i][1]
	dialogue_portrait = tutorial_lines[i][0]
	display_dialogue(dialogue_portrait, dialogue_text)

func play_random_dialogue(dialogue_array):
	is_loaded_dialogue_continuous = false
	i = randi_range(0, dialogue_array.size() - 1)
	dialogue_text = dialogue_array[i][1]
	dialogue_portrait = dialogue_array[i][0]
	display_dialogue(dialogue_portrait, dialogue_text)

func display_dialogue(portrait: portraits, dialogue : String):
	active_text_lines = tutorial_lines
	if is_displaying_dialogue == false:
		is_displaying_dialogue = true
		full_animation_player.play("dialogue_system_show")
	$PortraitAnimationPlayer.play("portrait_wobble")
	load_portrait(portrait)
	text_label.text = dialogue
	print("displaying dialogue")
	
	var t : Tween = get_tree().create_tween()
	$Textbox/TextLabel.visible_ratio = 0.0
	t.bind_node($Textbox/TextLabel)
	t.tween_property($Textbox/TextLabel, "visible_ratio", 1.0, 0.05 * dialogue.length())
	$TextScrollTimer.wait_time = 0.06 * dialogue.length() + 0.15
	$TextScrollTimer.start()
	
	#text_animation_player.play("text_scroll")


func load_portrait(action: portraits):
	match action:
		portraits.happy:
			character_portrait.texture = load("res://assets/game/lucky/dialog_actions/temp_action_smiling.png")
		portraits.angry:
			character_portrait.texture = load("res://assets/game/lucky/dialog_actions/temp_action_angry.png")

func _on_test_button_button_down() -> void:
	play_tutorial()
	$TestButton.visible = false


func _on_die_button_button_down() -> void:
	play_random_dialogue(defeat_lines)
	$dieButton.visible = false


func _on_win_button_button_down() -> void:
	play_random_dialogue(victory_lines)
	$winButton.visible = false


func _on_text_scroll_timer_timeout() -> void:
	$TextScrollTimer.stop()
