extends Node2D

@export var ore_cost: int = 2
@export var ingot_output: int = 1

func smelt(available_ore: int) -> int:
	if available_ore < ore_cost:
		return 0

	return ingot_output
