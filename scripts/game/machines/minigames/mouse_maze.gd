extends Minigame

@onready var Goal: Area2D = $Goal
@onready var Gear: Area2D = $Gear
@onready var gear_coll = $Gear/CollisionShape2D
var walls: Array[Area2D] = []

var started: bool = false
var last_mouse_pos: Vector2
var is_gear_selected: bool = false

func match_shape_to_rect(collider: CollisionShape2D, color_rect: ColorRect) -> void:
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = color_rect.size
	collider.shape = rect_shape
	collider.transform = color_rect.get_transform() * Transform2D(0.0, color_rect.size / 2.0)

func _ready() -> void:
	for wall: Area2D in get_tree().get_nodes_in_group("maze_wall"):
		walls.append(wall)
		var color_rect: ColorRect = null
		var collider: CollisionShape2D = null
		for node in wall.get_children():
			if node is ColorRect: color_rect = node
			if node is CollisionShape2D: collider = node
		if color_rect != null and collider != null:
			match_shape_to_rect(collider, color_rect)
		wall.area_entered.connect(wall_entered)
		
	last_mouse_pos = gear_coll.global_position
	
	Goal.area_entered.connect(goal_reached)

func start_minigame() -> void:
	started = true

func goal_reached(area: Area2D) -> void:
	if not started: return
	print("goal reached")
	minigame_completed.emit()
	
func wall_entered(area: Area2D) -> void:
	if not started: return
	print("body entered")
	minigame_failed.emit()

func _physics_process(_delta: float) -> void:
	if not started: return
	var mouse_global = get_global_mouse_position()
	
	if Input.is_action_just_released("left_click"):
		is_gear_selected = false
	
	if Input.is_action_just_pressed("left_click"):
		var mouse_to_centre_dist: float = mouse_global.distance_to(gear_coll.global_position)
		is_gear_selected = mouse_to_centre_dist < gear_coll.shape.radius
	elif not is_gear_selected:
		last_mouse_pos = mouse_global
	if not is_gear_selected: return
	
	var mouse_diff = mouse_global - last_mouse_pos
	Gear.translate(mouse_diff)
	last_mouse_pos = mouse_global
	
