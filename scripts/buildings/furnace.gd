extends Node2D

@export var coal_per_fuel: int = 2
@export var cycle_time: float = 3.0

var cycle_progress: float = 0.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	cycle_progress += delta
	if cycle_progress >= cycle_time:
		cycle_progress = 0.0
		# Conversion happens through building_manager

func convert_coal_to_fuel(available_coal: int) -> int:
	if available_coal < coal_per_fuel:
		return 0
	return 1

func smelt(available_ore: int) -> int:
	if available_ore < coal_per_fuel:
		return 0
	return 1
