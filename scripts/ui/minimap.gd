extends Panel

@export var padding: int = 8
@export var background_color: Color = Color(0.08, 0.08, 0.10, 0.94)
@export var border_color: Color = Color(0.6, 0.6, 0.7, 0.8)
@export var grid_color: Color = Color(0.18, 0.18, 0.22, 0.8)
@export var resource_color: Color = Color(0.84, 0.50, 0.18)
@export var player_color: Color = Color(0.96, 0.92, 0.28)
@export var building_color: Color = Color(0.40, 0.78, 0.40)

var world_node: Node = null

func _ready() -> void:
	world_node = get_tree().get_current_scene()
	if world_node == null:
		world_node = get_parent()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(true)
	queue_redraw()

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var rect = Rect2(Vector2.ZERO, size)
	draw_rect(rect, background_color, true)
	draw_rect(rect, border_color, false, 2.0)

	if world_node == null:
		return

	if not world_node.has_method("get_current_objective"):
		return

	var map_w = int(world_node.map_width)
	var map_h = int(world_node.map_height)
	var tile_size = float(world_node.tile_size)
	if map_w <= 0 or map_h <= 0 or tile_size <= 0:
		return

	var inner = Rect2(rect.position + Vector2(padding, padding), rect.size - Vector2(padding * 2, padding * 2))
	var cell_size = Vector2(inner.size.x / map_w, inner.size.y / map_h)

	for x in range(map_w + 1):
		var from = inner.position + Vector2(cell_size.x * x, 0)
		var to = inner.position + Vector2(cell_size.x * x, inner.size.y)
		draw_line(from, to, grid_color, 1.0)
	for y in range(map_h + 1):
		var from = inner.position + Vector2(0, cell_size.y * y)
		var to = inner.position + Vector2(inner.size.x, cell_size.y * y) + Vector2(0, 0)
		draw_line(from, to, grid_color, 1.0)

	var resources_root = null
	if world_node.has_node("Resources"):
		resources_root = world_node.get_node("Resources")
	if resources_root != null:
		for resource_node in resources_root.get_children():
			var position = resource_node.position / tile_size
			var center = inner.position + (position + Vector2(0.5, 0.5)) * cell_size
			draw_circle(center, 3.5, resource_color)

	if world_node.has_node("BuildingManager"):
		var building_manager = world_node.get_node("BuildingManager")
		if building_manager != null and building_manager.has_method("get_buildings_by_type") and building_manager.buildings.size() > 0:
			for building in building_manager.buildings:
				if building.node != null:
					var position = building.node.position / tile_size
					var center = inner.position + (position + Vector2(0.5, 0.5)) * cell_size
					draw_rect(Rect2(center - Vector2(3, 3), Vector2(6, 6)), building_color, true)

	if world_node.has_node("Player"):
		var player_node = world_node.get_node("Player")
		if player_node != null:
			var position = player_node.position / tile_size
			var center = inner.position + (position + Vector2(0.5, 0.5)) * cell_size
			draw_circle(center, 4.5, player_color)
