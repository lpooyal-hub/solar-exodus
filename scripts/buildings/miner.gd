extends Node2D

@export var ore_per_cycle: int = 1
@export var cycle_time: float = 2.0
@export var collect_range: float = 100.0

var resources_collected: Dictionary = {}
var cycle_progress: float = 0.0

func _ready() -> void:
	resources_collected = {"coal": 0, "iron": 0, "copper": 0}

func _process(delta: float) -> void:
	cycle_progress += delta
	if cycle_progress >= cycle_time:
		cycle_progress = 0.0
		# Mining happens through building_manager

func produce() -> int:
	return ore_per_cycle

func get_collected() -> Dictionary:
	return resources_collected.duplicate()

func add_resource(resource_type: String, amount: int) -> void:
	if resources_collected.has(resource_type):
		resources_collected[resource_type] += amount
