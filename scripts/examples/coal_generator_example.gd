extends Node2D

@onready var power_system: Node = $PowerSystem
@onready var generator: Node2D = $CoalGenerator
@onready var status_label: Label = $StatusLabel

func _ready() -> void:
	generator.add_coal(3)
	_update_status()

func _process(_delta: float) -> void:
	_update_status()

func _update_status() -> void:
	status_label.text = "Coal: %d | Power: %d | Running: %s" % [
		generator.get_coal_amount(),
		power_system.stored_power,
		str(generator.is_running)
	]
