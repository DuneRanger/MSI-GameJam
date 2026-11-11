extends Node2D

@export var difficulty : int = 0
@onready var player = $Player
@onready var lucky_sitting = $LuckySitting

@onready var camera: Camera2D = $Player/Camera2D
@onready var floor_layer: TileMapLayer = $Tilemap/TilemapFloorLayer
@onready var machine_layer = $Tilemap/TileMapMachineLayer

@onready var initial_player_pos : Vector2 = $Player.position

func _ready() -> void:
	for node in get_children():
		if node is Node2D:
			node.y_sort_enabled = true
	var rect = floor_layer.get_used_rect()
	var tile = floor_layer.tile_set.tile_size
	var top_left = floor_layer.to_global(rect.position * tile)
	var bottom_right = floor_layer.to_global(rect.end * tile)
	camera.limit_left = top_left.x
	camera.limit_top = top_left.y
	camera.limit_right = bottom_right.x
	camera.limit_bottom = bottom_right.y
	camera.reset_smoothing()

func start_level() -> void:
	player.position = initial_player_pos
	player.player_state = Player.player_states.WALKING

func level_over() -> void:
	player.player_state = Player.player_states.IN_DIALOGUE
	
