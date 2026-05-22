extends Node2D

@export var tile_size: int = 48
@export var map_width: int = 28
@export var map_height: int = 18
@export var resource_count: int = 18
@export var player_start: Vector2 = Vector2(3, 3)

const TILE_COLORS = [
	Color(0.16, 0.12, 0.07),
	Color(0.18, 0.16, 0.11),
	Color(0.12, 0.12, 0.14)
]
const RESOURCE_TYPES = ["coal", "iron", "copper", "fuel", "rocket_parts"]

var tiles: Array = []
var resource_positions: Array = []
var resource_inventory: Dictionary = {"coal": 0, "iron": 0, "copper": 0, "fuel": 0, "rocket_parts": 0}

@onready var resources_root: Node2D = $Resources
@onready var player_node: Node2D = $Player
@onready var hud: Node = $HUD
@onready var power_system: Node = $PowerSystem
@onready var pollution_system: Node = $PollutionSystem
@onready var generator: Node = $CoalGenerator
@onready var rocket_node: Node = $Rocket
var resource_scene: PackedScene = preload("res://scenes/world/resource_node.tscn")
var last_message: String = "Press H for help."
var show_help: bool = false

# Building manager
var building_manager: Node2D = null
var selected_building_type: int = -1
var placement_mode: bool = false

func _ready() -> void:
	randomize()
	generate_tiles()
	place_player()
	generate_resources()
	spawn_resources()
	
	# Create building manager
	building_manager = Node2D.new()
	building_manager.name = "BuildingManager"
	var bm_script = preload("res://scripts/systems/building_manager.gd")
	building_manager.set_script(bm_script)
	add_child(building_manager)
	
	update_hud()
	update()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_H:
				toggle_help()
			KEY_B:
				attempt_build_rocket()
			KEY_L:
				attempt_launch_rocket()
			KEY_U:
				attempt_upgrade_rocket()
			KEY_E:
				attempt_escape()
			KEY_1:
				select_building_type(0)
			KEY_2:
				select_building_type(1)
			KEY_3:
				select_building_type(2)
			KEY_4:
				select_building_type(3)
			KEY_ESCAPE:
				if placement_mode:
					placement_mode = false
					selected_building_type = -1
					send_message("Placement cancelled.")
				else:
					if building_manager != null:
						building_manager.deselect_building()
						send_message("Building deselected.")
	
	# Left click: place building or select building
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_local_mouse_position()
		if placement_mode:
			var grid_x = int(mouse_pos.x / tile_size)
			var grid_y = int(mouse_pos.y / tile_size)
			attempt_place_building(selected_building_type, Vector2(grid_x, grid_y))
		else:
			# Try to select building
			if building_manager != null and building_manager.has_method("get_building_at_position"):
				var building = building_manager.get_building_at_position(mouse_pos)
				if building != null:
					building_manager.select_building(building)
					send_message(building_manager.get_selected_building_info())

func _process(_delta: float) -> void:
	if generator != null and generator.has_method("get_coal_amount") and generator.get_coal_amount() <= 0:
		var coal_available := resource_inventory.get("coal", 0)
		if coal_available > 0:
			generator.add_coal(1)
			resource_inventory["coal"] = max(coal_available - 1, 0)
			update_hud()

	if building_manager != null and building_manager.has_method("process_buildings"):
		building_manager.process_buildings(resource_inventory, power_system, pollution_system, resources_root)

	update_hud()

func select_building_type(building_type: int) -> void:
	if building_manager == null:
		send_message("Building system not available.")
		return
	
	selected_building_type = building_type
	placement_mode = true
	var building_name = building_manager.get_building_name(building_type)
	send_message("Placing %s. Click to place." % building_name)

func attempt_place_building(building_type: int, grid_pos: Vector2) -> void:
	if building_manager == null:
		send_message("Building system not available.")
		return
	
	if not building_manager.can_place_building(building_type, grid_pos, resource_inventory):
		send_message("Cannot place building there.")
		return
	
	var building = building_manager.place_building(building_type, grid_pos, resource_inventory)
	if building != null:
		var building_name = building_manager.get_building_name(building_type)
		send_message("%s placed." % building_name)
		placement_mode = false
		selected_building_type = -1
	else:
		send_message("Failed to place building.")

func send_message(text: String) -> void:
	last_message = text

func attempt_build_rocket() -> void:
	if rocket_node == null:
		send_message("Rocket system unavailable.")
		return
	if rocket_node.has_method("build_initial") and rocket_node.build_initial(resource_inventory):
		send_message("Initial rocket built. Press L to launch when enough fuel is loaded.")
	else:
		send_message("Not enough parts or fuel to build the rocket.")

func attempt_launch_rocket() -> void:
	if rocket_node == null:
		send_message("Rocket system unavailable.")
		return
	if rocket_node.has_method("launch_initial") and rocket_node.launch_initial(resource_inventory):
		send_message("Nearby planet reached. Gather more resources, then press U to upgrade.")
	else:
		send_message("Launch failed. Build rocket first and ensure enough fuel.")

func attempt_upgrade_rocket() -> void:
	if rocket_node == null:
		send_message("Rocket system unavailable.")
		return
	if rocket_node.has_method("upgrade_to_escape") and rocket_node.upgrade_to_escape(resource_inventory):
		send_message("Rocket upgraded. Press E to escape the solar system when fuel is ready.")
	else:
		send_message("Upgrade failed. Need more parts or a completed initial launch.")

func attempt_escape() -> void:
	if rocket_node == null:
		send_message("Rocket system unavailable.")
		return
	if rocket_node.has_method("escape_solar_system") and rocket_node.escape_solar_system(resource_inventory):
		send_message("Victory! Solar system escaped.")
	else:
		send_message("Escape failed. Upgrade rocket and ensure enough fuel.")

func generate_tiles() -> void:
	tiles.clear()
	for y in range(map_height):
		for x in range(map_width):
			var chance = randf()
			if chance < 0.16:
				tiles.append(2)
			elif chance < 0.42:
				tiles.append(1)
			else:
				tiles.append(0)

func place_player() -> void:
	if player_node != null:
		player_node.position = player_start * tile_size

func generate_resources() -> void:
	resource_positions.clear()
	var max_attempts := resource_count * 3
	while resource_positions.size() < resource_count and max_attempts > 0:
		max_attempts -= 1
		var x := randi() % map_width
		var y := randi() % map_height
		var position := Vector2(x * tile_size + tile_size * 0.5, y * tile_size + tile_size * 0.5)
		if position.distance_to(player_node.position) < tile_size * 3:
			continue
		var too_close := false
		for existing in resource_positions:
			if position.distance_to(existing) < tile_size * 2:
				too_close = true
				break
		if too_close:
			continue
		resource_positions.append(position)

func spawn_resources() -> void:
	for child in resources_root.get_children():
		child.queue_free()
	for position in resource_positions:
		var resource := resource_scene.instantiate()
		resource.position = position
		if resource.has_method("set_resource_type"):
			resource.set_resource_type(RESOURCE_TYPES[randi() % RESOURCE_TYPES.size()])
		if resource.has_method("set_amount"):
			resource.set_amount(6 + randi() % 6)
		if resource.has_method("connect"):
			resource.connect("collected", Callable(self, "_on_resource_collected"))
		resources_root.add_child(resource)

func _on_resource_collected(resource_type: String, amount: int) -> void:
	resource_inventory[resource_type] = resource_inventory.get(resource_type, 0) + amount
	update_hud()

func update_hud() -> void:
	if hud == null:
		return
	if hud.has_method("set_all_resources"):
		hud.set_all_resources(resource_inventory)
	if hud.has_method("set_power") and power_system != null:
		hud.set_power(power_system.stored_power)
	if hud.has_method("set_pollution") and pollution_system != null:
		hud.set_pollution(pollution_system.pollution)
	if hud.has_method("set_rocket_status") and rocket_node != null:
		hud.set_rocket_status(rocket_node.get_status_text())
	if hud.has_method("set_objective"):
		hud.set_objective(get_current_objective())
	if hud.has_method("set_message"):
		hud.set_message(last_message)
	if hud.has_method("set_building_info") and building_manager != null:
		hud.set_building_info(building_manager.get_selected_building_info())

func _draw() -> void:
	for y in range(map_height):
		for x in range(map_width):
			var index := x + y * map_width
			var tile_type := tiles[index]
			var tile_color := TILE_COLORS[tile_type]
			draw_rect(Rect2(x * tile_size, y * tile_size, tile_size, tile_size), tile_color, true)
			if (x + y) % 2 == 0:
				draw_rect(Rect2(x * tile_size, y * tile_size, tile_size, tile_size), Color(1, 1, 1, 0.04), false, 1.0)

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAW:
		pass

func get_current_objective() -> String:
	if rocket_node == null:
		return "Find rocket components."
	var stage := rocket_node.stage if rocket_node.has_property("stage") else 0
	match stage:
		0:
			return "Collect rocket parts and fuel to build your first rocket."
		1:
			return "Load fuel and launch to reach a nearby planet."
		2:
			return "Gather advanced resources and parts for the escape upgrade."
		3:
			return "Load escape fuel and break out of the solar system."
		4:
			return "Solar system escaped!" 
		_:
			return "Explore, collect resources, and prepare the rocket."

func toggle_help() -> void:
	show_help = not show_help
	if show_help:
		send_message("Controls: H help, B build, L launch, U upgrade, E escape. 1-4 place buildings.")
	else:
		send_message("Help hidden. Keep collecting resources.")
