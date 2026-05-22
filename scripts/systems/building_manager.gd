extends Node2D

const GRID_SIZE: int = 48

var buildings: Array = []
var world: Node2D = null

# Building types
enum BuildingType {
	MINER,
	FUEL_FURNACE,
	GENERATOR,
	STORAGE
}

var building_costs: Dictionary = {
	BuildingType.MINER: {"coal": 5, "iron": 3},
	BuildingType.FUEL_FURNACE: {"coal": 3, "iron": 2},
	BuildingType.GENERATOR: {"coal": 2, "iron": 4},
	BuildingType.STORAGE: {"coal": 1, "iron": 5}
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
	
	func _init(p_type: int, p_position: Vector2, p_cost: Dictionary):
		type = p_type
		position = p_position
		cost = p_cost.duplicate()
		node = null

func _ready() -> void:
	world = get_parent()

func can_place_building(building_type: int, grid_pos: Vector2, inventory: Dictionary) -> bool:
	# Check if position is valid
	if grid_pos.x < 0 or grid_pos.y < 0 or grid_pos.x >= 28 or grid_pos.y >= 18:
		return false
	
	# Check if position is occupied
	for building in buildings:
		if building.position == grid_pos:
			return false
	
	# Check if inventory has enough resources
	var cost = building_costs[building_type]
	for resource in cost:
		if inventory.get(resource, 0) < cost[resource]:
			return false
	
	return true

func place_building(building_type: int, grid_pos: Vector2, inventory: Dictionary) -> Building:
	if not can_place_building(building_type, grid_pos, inventory):
		return null
	
	# Deduct cost from inventory
	var cost = building_costs[building_type]
	for resource in cost:
		inventory[resource] = max(0, inventory.get(resource, 0) - cost[resource])
	
	# Create building
	var building = Building.new(building_type, grid_pos, cost)
	
	# Create visual node
	var node = Node2D.new()
	node.name = "Building_" + str(building_type)
	node.position = grid_pos * GRID_SIZE + Vector2(GRID_SIZE / 2, GRID_SIZE / 2)
	
	# Add visual representation
	var sprite = Polygon2D.new()
	sprite.polygon = PackedVector2Array([
		Vector2(-16, -16), Vector2(16, -16), Vector2(16, 16), Vector2(-16, 16)
	])
	
	match building_type:
		BuildingType.MINER:
			sprite.color = Color(0.5, 0.5, 0.5)  # Gray
		BuildingType.FUEL_FURNACE:
			sprite.color = Color(1.0, 0.5, 0.0)  # Orange
		BuildingType.GENERATOR:
			sprite.color = Color(1.0, 0.8, 0.0)  # Yellow
		BuildingType.STORAGE:
			sprite.color = Color(0.5, 0.5, 1.0)  # Blue
	
	node.add_child(sprite)
	
	# Add label
	var label = Label.new()
	label.text = get_building_name(building_type)
	label.add_theme_font_size_override("font_size", 8)
	label.position = Vector2(-16, -20)
	node.add_child(label)
	
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
	var name = get_building_name(building_type)
	var cost = building_costs[building_type]
	var cost_str = ""
	for resource in cost:
		if cost_str != "":
			cost_str += ", "
		cost_str += str(cost[resource]) + " " + resource
	return "%s (Cost: %s)" % [name, cost_str]

func process_buildings(inventory: Dictionary, power_system: Node, pollution_system: Node, resources_root: Node2D) -> void:
	# Miners collect resources from the map
	for building in get_buildings_by_type(BuildingType.MINER):
		if building.node != null:
			var collected = collect_nearby_resources(building.node.position, resources_root)
			for resource in collected:
				inventory[resource] = inventory.get(resource, 0) + collected[resource]
	
	# Fuel furnaces convert coal to fuel
	for building in get_buildings_by_type(BuildingType.FUEL_FURNACE):
		if inventory.get("coal", 0) >= 2:
			inventory["coal"] -= 2
			inventory["fuel"] = inventory.get("fuel", 0) + 1
	
	# Generators convert fuel to power
	for building in get_buildings_by_type(BuildingType.GENERATOR):
		if inventory.get("fuel", 0) >= 1 and power_system != null:
			inventory["fuel"] -= 1
			power_system.add_power(25)
			if pollution_system != null:
				pollution_system.add_pollution(2.0)

func collect_nearby_resources(position: Vector2, resources_root: Node2D) -> Dictionary:
	var collected: Dictionary = {}
	var collect_range: float = 100.0
	
	for resource_node in resources_root.get_children():
		if position.distance_to(resource_node.position) < collect_range:
			if resource_node.has_method("get_type") and resource_node.has_method("get_amount"):
				var resource_type = resource_node.get_type()
				var amount = resource_node.get_amount()
				if amount > 0:
					collected[resource_type] = collected.get(resource_type, 0) + amount
					resource_node.collect(amount)
	
	return collected
