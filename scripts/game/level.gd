extends Node2D

@export var difficulty : int = 0
@onready var player = $Player
@onready var lucky_sitting = $LuckySitting
@onready var machine_layer = $Tilemap/TileMapMachineLayer

func _ready() -> void:
	for node in get_children():
		if node is Node2D:
			node.y_sort_enabled = true
