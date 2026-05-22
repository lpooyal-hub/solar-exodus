extends Node

var stored_power: int = 0
var power_capacity: int = 100

func add_power(amount: int) -> void:
	stored_power = clampi(stored_power + amount, 0, power_capacity)

func consume_power(amount: int) -> bool:
	if stored_power < amount:
		return false

	stored_power -= amount
	return true
