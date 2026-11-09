extends Minigame

@onready var Goal: Area2D = $Goal
@onready var Battery: Area2D = $Battery
@onready var gear_coll = $Battery/CollisionShape2D
var walls: Array[Area2D] = []

var started: bool = false
var last_mouse_pos: Vector2
var is_gear_selected: bool = false
var failed: bool = false
var was_goal_reached: bool = false

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
	$Timer.start()

func goal_reached(area: Area2D) -> void:
	if not started: return
	if area == Battery and not failed:
		was_goal_reached = true
		print("goal reached", started)
		minigame_completed.emit()
	
func wall_entered(area: Area2D) -> void:
	if not started: return
	if area == Battery and not was_goal_reached:
		failed = true
		print("body entered", started)
		play_failure_sound()
		minigame_failed.emit()

func _physics_process(_delta: float) -> void:
	if not started or failed or was_goal_reached: return
	var mouse_global = get_global_mouse_position()
	
	if Input.is_action_just_released("left_click"):
		is_gear_selected = false
	
	if Input.is_action_just_pressed("left_click"):
		var shape: RectangleShape2D = gear_coll.shape
		var x_dist = Vector2(mouse_global.x, 0).distance_to(Vector2(gear_coll.global_position.x, 0))
		var y_dist = Vector2(0, mouse_global.y).distance_to(Vector2(0, gear_coll.global_position.y))
		is_gear_selected = x_dist < shape.size.x and y_dist < shape.size.y
	elif not is_gear_selected:
		last_mouse_pos = mouse_global
	if not is_gear_selected: return
	
	var mouse_diff = mouse_global - last_mouse_pos
	Battery.translate(mouse_diff)
	last_mouse_pos = mouse_global

func _on_timer_timout() -> void:
	if not was_goal_reached:
		minigame_failed.emit()
		play_failure_sound()
