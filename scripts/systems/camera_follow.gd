extends Camera2D

@export var target_path: NodePath
@export var smoothing_speed: float = 6.0
@export var deadzone_size: Vector2 = Vector2(96, 64)
@export var use_deadzone: bool = true
@export var limit_rect: Rect2 = Rect2(0, 0, 0, 0)

var target: Node2D = null

func _ready() -> void:
	if not target_path.is_empty() and has_node(target_path):
		target = get_node(target_path)
	if target:
		make_current()
	if limit_rect.size == Vector2.ZERO:
		var root: Node = get_tree().get_current_scene()
		if root != null:
			var tile_size = root.get("tile_size")
			var map_width = root.get("map_width")
			var map_height = root.get("map_height")
			if tile_size != null and map_width != null and map_height != null:
				limit_rect = Rect2(Vector2.ZERO, Vector2(tile_size * map_width, tile_size * map_height))

func _physics_process(delta: float) -> void:
	if target == null:
		return
	var target_pos: Vector2 = target.global_position
	var follow_pos: Vector2 = global_position
	if use_deadzone:
		var deadzone = Rect2(follow_pos - deadzone_size * 0.5, deadzone_size)
		if not deadzone.has_point(target_pos):
			follow_pos = follow_pos.lerp(target_pos, clamp(smoothing_speed * delta, 0.0, 1.0))
	else:
		follow_pos = follow_pos.lerp(target_pos, clamp(smoothing_speed * delta, 0.0, 1.0))
	global_position = _clamp_to_limits(follow_pos)

func _clamp_to_limits(position: Vector2) -> Vector2:
	if limit_rect.size == Vector2.ZERO:
		return position
	var half_size = get_viewport_rect().size * 0.5 * zoom
	var min_pos = limit_rect.position + half_size
	var max_pos = limit_rect.position + limit_rect.size - half_size
	return Vector2(
		clamp(position.x, min_pos.x, max_pos.x),
		clamp(position.y, min_pos.y, max_pos.y)
	)
