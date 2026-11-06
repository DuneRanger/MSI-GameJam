class_name MachineType
extends Resource

# Visuals
@export var sprite_frames: SpriteFrames

# Heat parameters
@export var spike_chance_per_second: float = 0.05
@export var spike_multiplier: float = 1.5
@export var explosion_temperature: float = 250.0
@export var overheat_temperature: float = 100.0
@export var heat_rate: float = 5.0

# Minigame
@export var minigame_id: int = 0
