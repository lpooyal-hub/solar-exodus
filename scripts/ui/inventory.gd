extends Control

@onready var coal_label: Label = $Panel/VBoxContainer/CoalLabel
@onready var iron_label: Label = $Panel/VBoxContainer/IronLabel
@onready var copper_label: Label = $Panel/VBoxContainer/CopperLabel
@onready var fuel_label: Label = $Panel/VBoxContainer/FuelLabel
@onready var parts_label: Label = $Panel/VBoxContainer/PartsLabel

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_resources({"coal": 0, "iron": 0, "copper": 0, "fuel": 0, "rocket_parts": 0})

func set_resources(resources: Dictionary) -> void:
	coal_label.text = "Coal: %d" % int(resources.get("coal", 0))
	iron_label.text = "Iron: %d" % int(resources.get("iron", 0))
	copper_label.text = "Copper: %d" % int(resources.get("copper", 0))
	fuel_label.text = "Fuel: %d" % int(resources.get("fuel", 0))
	parts_label.text = "Rocket Parts: %d" % int(resources.get("rocket_parts", 0))
