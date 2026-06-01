extends Node2D

const GRID_SIZE: int = 48
const MINER_CYCLE_TIME: float = 3.0
const FURNACE_CYCLE_TIME: float = 4.0
const GENERATOR_CYCLE_TIME: float = 2.0
const MINER_COLLECT_RANGE: float = 100.0
const FURNACE_COAL_COST: int = 2
const GENERATOR_FUEL_COST: int = 1
const GENERATOR_POWER_OUTPUT: int = 25
const GENERATOR_POLLUTION_OUTPUT: float = 2.0

var buildings: Array = []
var world: Node2D = null
var selected_building = null

# Building types
enum BuildingType {
	MINER,
	FUEL_FURNACE,
	GENERATOR,
	STORAGE
}

# Building states
enum BuildingState {
	IDLE,
	WORKING,
	STARVING,
	ERROR
}

var building_costs: Dictionary = {
	BuildingType.MINER: {"coal": 5, "iron": 3},
	BuildingType.FUEL_FURNACE: {"coal": 3, "iron": 2},
	BuildingType.GENERATOR: {"coal": 2, "iron": 4},
	BuildingType.STORAGE: {"coal": 1, "iron": 5}
}

var state_colors: Dictionary = {
	BuildingState.IDLE: Color(0.5, 0.5, 0.5),
	BuildingState.WORKING: Color(0.0, 1.0, 0.0),
	BuildingState.STARVING: Color(1.0, 1.0, 0.0),
	BuildingState.ERROR: Color(1.0, 0.0, 0.0)
}

var building_scripts: Dictionary = {
	BuildingType.MINER: preload("res://scripts/buildings/miner.gd"),
	BuildingType.FUEL_FURNACE: preload("res://scripts/buildings/furnace.gd"),
	BuildingType.GENERATOR: preload("res://scripts/buildings/generator.gd"),
	BuildingType.STORAGE: null
}

class Building:
	var type: int
	var position: Vector2
	var node: Node2D
	var cost: Dictionary
	var state: int = 0  # IDLE
	var sprite: Polygon2D = null
	var label: Label = null
	var state_indicator: Node2D = null
	var cycle_progress: float = 0.0

	func _init(p_type: int, p_position: Vector2, p_cost: Dictionary):
		type = p_type
		position = p_position
		cost = p_cost.duplicate()
		node = null
		state = 0

func _ready() -> void:
	world = get_parent()

func can_place_building(building_type: int, grid_pos: Vector2, inventory: Dictionary) -> bool:
	if not building_costs.has(building_type):
		return false

	if grid_pos.x < 0 or grid_pos.y < 0 or grid_pos.x >= 28 or grid_pos.y >= 18:
		return false

	for building in buildings:
		if building.position == grid_pos:
			return false

	var cost = building_costs[building_type]
	for resource in cost:
		if inventory.get(resource, 0) < cost[resource]:
			return false

	return true

func place_building(building_type: int, grid_pos: Vector2, inventory: Dictionary) -> Building:
	if not can_place_building(building_type, grid_pos, inventory):
		return null

	var cost = building_costs[building_type]
	for resource in cost:
		inventory[resource] = max(0, inventory.get(resource, 0) - cost[resource])

	var building = Building.new(building_type, grid_pos, cost)

	var node = Node2D.new()
	node.name = "Building_" + str(building_type)
	node.position = grid_pos * GRID_SIZE + Vector2(GRID_SIZE / 2, GRID_SIZE / 2)

	# Main building sprite
	var sprite = Polygon2D.new()
	sprite.polygon = PackedVector2Array([
		Vector2(-16, -16), Vector2(16, -16), Vector2(16, 16), Vector2(-16, 16)
	])
	sprite.color = state_colors[BuildingState.IDLE]
	node.add_child(sprite)
	building.sprite = sprite

	# Label
	var label = Label.new()
	label.text = get_building_name(building_type)
	label.add_theme_font_size_override("font_size", 8)
	label.position = Vector2(-16, -20)
	node.add_child(label)
	building.label = label

	# State indicator (progress dot)
	var indicator = Node2D.new()
	var indicator_circle = CircleShape2D.new()
	node.add_child(indicator)
	building.state_indicator = indicator

	building.node = node
	add_child(node)

	buildings.append(building)
	return building

func remove_building(building: Building) -> void:
	if building.node != null:
		building.node.queue_free()
	buildings.erase(building)

func get_buildings_by_type(building_type: int) -> Array:
	var result: Array = []
	for building in buildings:
		if building.type == building_type:
			result.append(building)
	return result

func get_building_name(building_type: int) -> String:
	match building_type:
		BuildingType.MINER:
			return "Miner"
		BuildingType.FUEL_FURNACE:
			return "Furnace"
		BuildingType.GENERATOR:
			return "Generator"
		BuildingType.STORAGE:
			return "Storage"
		_:
			return "Unknown"

func get_building_info(building_type: int) -> String:
	if not building_costs.has(building_type):
		return "Unknown"
	var name = get_building_name(building_type)
	var cost = building_costs[building_type]
	var cost_str = ""
	for resource in cost:
		if cost_str != "":
			cost_str += ", "
		cost_str += str(cost[resource]) + " " + resource
	return "%s (Cost: %s)" % [name, cost_str]

func get_build_menu_text() -> String:
	var lines: Array[String] = []
	for building_type in BuildingType.values():
		lines.append("%d: %s" % [int(building_type) + 1, get_building_info(building_type)])
	return "\n".join(lines)

func get_place_failure_reason(building_type: int, grid_pos: Vector2, inventory: Dictionary) -> String:
	if not building_costs.has(building_type):
		return "Unknown building."
	if grid_pos.x < 0 or grid_pos.y < 0 or grid_pos.x >= 28 or grid_pos.y >= 18:
		return "Outside buildable area."
	for building in buildings:
		if building.position == grid_pos:
			return "Tile already occupied."

	var missing: Array[String] = []
	var cost = building_costs[building_type]
	for resource in cost:
		var needed: int = int(cost[resource])
		var owned: int = int(inventory.get(resource, 0))
		if owned < needed:
			missing.append("%s %d/%d" % [resource, owned, needed])
	if missing.size() > 0:
		return "Missing " + ", ".join(missing) + "."
	return "Cannot place building there."

func get_state_name(state: int) -> String:
	match state:
		BuildingState.IDLE:
			return "Idle"
		BuildingState.WORKING:
			return "Working"
		BuildingState.STARVING:
			return "Starving"
		BuildingState.ERROR:
			return "Error"
		_:
			return "Unknown"

func process_buildings(delta: float, inventory: Dictionary, power_system: Node, pollution_system: Node, resources_root: Node2D) -> void:
	# Miners collect resources from the map
	for building in get_buildings_by_type(BuildingType.MINER):
		building.cycle_progress += delta
		if building.cycle_progress < MINER_CYCLE_TIME:
			continue
		building.cycle_progress = 0.0

		var collected = collect_nearby_resources(building.node.position, resources_root)
		if collected.size() > 0:
			building.state = BuildingState.WORKING
			for resource in collected:
				inventory[resource] = inventory.get(resource, 0) + collected[resource]
		else:
			building.state = BuildingState.STARVING

	# Fuel furnaces convert coal to fuel
	for building in get_buildings_by_type(BuildingType.FUEL_FURNACE):
		building.cycle_progress += delta
		if building.cycle_progress < FURNACE_CYCLE_TIME:
			continue
		building.cycle_progress = 0.0

		if inventory.get("coal", 0) >= FURNACE_COAL_COST:
			inventory["coal"] -= FURNACE_COAL_COST
			inventory["fuel"] = inventory.get("fuel", 0) + 1
			building.state = BuildingState.WORKING
		else:
			building.state = BuildingState.STARVING

	# Generators convert fuel to power
	for building in get_buildings_by_type(BuildingType.GENERATOR):
		building.cycle_progress += delta
		if building.cycle_progress < GENERATOR_CYCLE_TIME:
			continue
		building.cycle_progress = 0.0

		if power_system != null and inventory.get("fuel", 0) >= GENERATOR_FUEL_COST:
			inventory["fuel"] -= GENERATOR_FUEL_COST
			power_system.add_power(GENERATOR_POWER_OUTPUT)
			if pollution_system != null:
				pollution_system.add_pollution(GENERATOR_POLLUTION_OUTPUT)
			building.state = BuildingState.WORKING
		else:
			building.state = BuildingState.STARVING

	# Update visuals for all buildings
	for building in buildings:
		if building.sprite != null:
			building.sprite.color = state_colors[building.state]

func collect_nearby_resources(position: Vector2, resources_root: Node2D) -> Dictionary:
	var collected: Dictionary = {}

	for resource_node in resources_root.get_children():
		if position.distance_to(resource_node.position) < MINER_COLLECT_RANGE:
			if resource_node.has_method("get_type") and resource_node.has_method("get_amount"):
				var resource_type = resource_node.get_type()
				var amount = resource_node.get_amount()
				if amount > 0:
					collected[resource_type] = collected.get(resource_type, 0) + amount
					resource_node.collect(amount)

	return collected

func get_building_at_position(world_pos: Vector2) -> Building:
	for building in buildings:
		if building.node != null:
			var dist = building.node.position.distance_to(world_pos)
			if dist < GRID_SIZE:
				return building
	return null

func select_building(building: Building) -> void:
	selected_building = building
	if building != null and building.node != null:
		building.node.modulate = Color(1.2, 1.2, 1.2)
	# Deselect others
	for b in buildings:
		if b != building and b.node != null:
			b.node.modulate = Color(1.0, 1.0, 1.0)

func deselect_building() -> void:
	if selected_building != null and selected_building.node != null:
		selected_building.node.modulate = Color(1.0, 1.0, 1.0)
	selected_building = null

func get_selected_building_info() -> String:
	if selected_building == null:
		return ""
	var name = get_building_name(selected_building.type)
	var state = get_state_name(selected_building.state)
	return "%s: %s" % [name, state]
