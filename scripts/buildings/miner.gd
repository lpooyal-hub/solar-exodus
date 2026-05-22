extends Node2D

@export var ore_per_cycle: int = 1
@export var cycle_time: float = 2.0

func produce() -> int:
	return ore_per_cycle
