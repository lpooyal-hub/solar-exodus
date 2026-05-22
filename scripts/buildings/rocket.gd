extends Node2D

@export var initial_requirements: Dictionary = {
	"rocket_parts": 4,
	"fuel": 8
}

@export var upgrade_requirements: Dictionary = {
	"rocket_parts": 6,
	"fuel": 12
}

@export var launch_fuel_cost: int = 5
@export var escape_fuel_cost: int = 14

var stage: int = 0

func get_status_text() -> String:
	match stage:
		0:
			return "Rocket: not built"
		1:
			return "Rocket built"
		2:
			return "Nearby planet reached"
		3:
			return "Rocket upgraded"
		4:
			return "Solar system escaped!"
		_:
			return "Rocket: unknown state"

func get_next_requirements() -> Dictionary:
	match stage:
		0:
			return initial_requirements
		2:
			return upgrade_requirements
		_:
			return {}

func _can_pay(requirements: Dictionary, inventory: Dictionary) -> bool:
	for key in requirements.keys():
		if inventory.get(key, 0) < requirements[key]:
			return false
	return true

func build_initial(inventory: Dictionary) -> bool:
	if stage != 0:
		return false
	if not _can_pay(initial_requirements, inventory):
		return false
	for key in initial_requirements.keys():
		inventory[key] = inventory.get(key, 0) - initial_requirements[key]
	stage = 1
	return true

func launch_initial(inventory: Dictionary) -> bool:
	if stage != 1:
		return false
	if inventory.get("fuel", 0) < launch_fuel_cost:
		return false
	inventory["fuel"] = inventory.get("fuel", 0) - launch_fuel_cost
	stage = 2
	return true

func upgrade_to_escape(inventory: Dictionary) -> bool:
	if stage != 2:
		return false
	if not _can_pay(upgrade_requirements, inventory):
		return false
	for key in upgrade_requirements.keys():
		inventory[key] = inventory.get(key, 0) - upgrade_requirements[key]
	stage = 3
	return true

func escape_solar_system(inventory: Dictionary) -> bool:
	if stage != 3:
		return false
	if inventory.get("fuel", 0) < escape_fuel_cost:
		return false
	inventory["fuel"] = inventory.get("fuel", 0) - escape_fuel_cost
	stage = 4
	return true
