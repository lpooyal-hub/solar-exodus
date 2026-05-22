extends Node

var pollution: float = 0.0

func add_pollution(amount: float) -> void:
	pollution = maxf(0.0, pollution + amount)

func reduce_pollution(amount: float) -> void:
	pollution = maxf(0.0, pollution - amount)
