extends Control

@onready var text_animation_player = $TextScrollAnimationPlayer
@onready var full_animation_player = $FullAnimationPlayer
@onready var character_portrait = $Portrait/CharacterPortrait
@onready var text_label = $Textbox/TextLabel
var is_displaying_dialogue = false
var dialogue_source
var dialogue_text
var dialogue_portrait : portraits
var is_loaded_dialogue_continuous = false
var i = 0

var tutorial_lines = [
	[portraits.happy, "Hello"],
	[portraits.angry, "grrrr im angry now"],
	[portraits.angry, "grr im still angry"],
	[portraits.happy, "Hello"]
]

var active_text_lines

enum portraits {happy, angry}

func _process(delta: float) -> void:
	if is_displaying_dialogue == true and is_loaded_dialogue_continuous == true:
		if Input.is_action_just_pressed("dialogue_skip"):
			if i != active_text_lines.size() - 1:
				if text_animation_player.is_playing() != true:
					i += 1
					dialogue_text = active_text_lines[i][1]
					dialogue_portrait = active_text_lines[i][0]
					display_dialogue(dialogue_portrait ,dialogue_text)
			else:
				print("konec")
				text_label.text = ""
				full_animation_player.play("dialogue_system_hide")
				is_displaying_dialogue = false
	pass

func play_tutorial():
	is_loaded_dialogue_continuous = true
	dialogue_text = tutorial_lines[i][1]
	dialogue_portrait = tutorial_lines[i][0]
	display_dialogue(dialogue_portrait, dialogue_text)
	
# Called when the node enters the scene tree for the first time.
func display_dialogue(portrait: portraits, dialogue : String):
	active_text_lines = tutorial_lines
	if is_displaying_dialogue == false:
		is_displaying_dialogue = true
		full_animation_player.play("dialogue_system_show")
	$PortraitAnimationPlayer.play("portrait_wobble")
	load_portrait(portrait)
	text_label.text = dialogue
	text_animation_player.play("text_scroll")


func load_portrait(action: portraits):
	match action:
		portraits.happy:
			character_portrait.texture = load("res://assets/game/lucky/dialog_actions/temp_action_smiling.png")
		portraits.angry:
			character_portrait.texture = load("res://assets/game/lucky/dialog_actions/temp_action_angry.png")

func _on_test_button_button_down() -> void:
	display_dialogue(portraits.angry, "Fuck you bitch")
	play_tutorial()
	$TestButton.visible = false
