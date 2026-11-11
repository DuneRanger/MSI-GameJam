extends Node

@export var title_screen : Node2D 

@export var game_scene : PackedScene
var game : Node

enum scene_states {TITLE, GAME}
var scene_state : scene_states

func _ready() -> void:
	scene_state = scene_states.TITLE
	game = null

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_play_button_pressed() -> void:
	if game == null:
		game = game_scene.instantiate()
		game.return_to_menu.connect(show_title)
	
	show_game()
	game.start_new_game()

func show_title() -> void:
	remove_child(game)
	game = null
	add_child(title_screen)
	
func show_game() -> void:
	remove_child(title_screen)
	add_child(game)
