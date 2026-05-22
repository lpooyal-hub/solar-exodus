extends Node2D

@export var power_per_cycle: int = 25
@export var cycle_time: float = 1.0
@export var starting_coal: int = 5
@export var pollution_per_coal: float = 4.0
@export_node_path("Node") var power_system_path: NodePath
@export_node_path("Node") var pollution_system_path: NodePath

var coal: int = 0
var cycle_progress: float = 0.0
var is_running: bool = false

@onready var power_system: Node = get_node_or_null(power_system_path)
@onready var pollution_system: Node = get_node_or_null(pollution_system_path)

func _ready() -> void:
	coal = starting_coal
	is_running = coal > 0

func _process(delta: float) -> void:
	if coal <= 0:
		is_running = false
		cycle_progress = 0.0
		return

	if power_system == null:
		is_running = false
		return

	is_running = true
	cycle_progress += delta

	if cycle_progress < cycle_time:
		return

	cycle_progress = 0.0
	coal -= 1
	power_system.add_power(power_per_cycle)
	if pollution_system != null:
		pollution_system.add_pollution(pollution_per_coal)

	if coal <= 0:
		is_running = false

func add_coal(amount: int) -> void:
	if amount <= 0:
		return

	coal += amount
	if power_system != null:
		is_running = true

func get_coal_amount() -> int:
	return coal

func generate_power() -> int:
	return power_per_cycle
