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
var last_message: String = "Press B to build a rocket."

func _ready() -> void:
	randomize()
	generate_tiles()
	place_player()
	generate_resources()
	spawn_resources()
	update_hud()
	update()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_B:
				attempt_build_rocket()
			KEY_L:
				attempt_launch_rocket()
			KEY_U:
				attempt_upgrade_rocket()
			KEY_E:
				attempt_escape()

func _process(_delta: float) -> void:
	if generator != null and generator.has_method("get_coal_amount") and generator.get_coal_amount() <= 0:
		var coal_available := resource_inventory.get("coal", 0)
		if coal_available > 0:
			generator.add_coal(1)
			resource_inventory["coal"] = max(coal_available - 1, 0)
			update_hud()

	update_hud()

func send_message(text: String) -> void:
	last_message = text

func attempt_build_rocket() -> void:
	if rocket_node == null:
		send_message("Rocket system unavailable.")
		return
	if rocket_node.has_method("build_initial") and rocket_node.build_initial(resource_inventory):
		send_message("Initial rocket built. Press L to launch.")
	else:
		send_message("Not enough resources to build the rocket.")

func attempt_launch_rocket() -> void:
	if rocket_node == null:
		send_message("Rocket system unavailable.")
		return
	if rocket_node.has_method("launch_initial") and rocket_node.launch_initial(resource_inventory):
		send_message("Nearby planet reached. Collect more resources and press U to upgrade.")
	else:
		send_message("Rocket must be built first before launching, or fuel is too low.")

func attempt_upgrade_rocket() -> void:
	if rocket_node == null:
		send_message("Rocket system unavailable.")
		return
	if rocket_node.has_method("upgrade_to_escape") and rocket_node.upgrade_to_escape(resource_inventory):
		send_message("Rocket upgraded. Press E to escape the solar system.")
	else:
		send_message("Cannot upgrade rocket yet. Reach nearby planet and check resources.")

func attempt_escape() -> void:
	if rocket_node == null:
		send_message("Rocket system unavailable.")
		return
	if rocket_node.has_method("escape_solar_system") and rocket_node.escape_solar_system(resource_inventory):
		send_message("Victory! Solar system escaped.")
	else:
		send_message("Rocket must be upgraded before escaping, or fuel is too low.")

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

func send_message(text: String) -> void:
	last_message = text

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
	if hud.has_method("set_message"):
		hud.set_message(last_message)

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
