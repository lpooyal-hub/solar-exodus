extends CanvasLayer

@onready var coal_label: Label = $Panel/VBoxContainer/CoalLabel
@onready var iron_label: Label = $Panel/VBoxContainer/IronLabel
@onready var copper_label: Label = $Panel/VBoxContainer/CopperLabel
@onready var fuel_label: Label = $Panel/VBoxContainer/FuelLabel
@onready var parts_label: Label = $Panel/VBoxContainer/PartsLabel
@onready var power_label: Label = $Panel/VBoxContainer/PowerLabel
@onready var pollution_label: Label = $Panel/VBoxContainer/PollutionLabel
@onready var rocket_label: Label = $Panel/VBoxContainer/RocketLabel
@onready var message_label: Label = $Panel/VBoxContainer/MessageLabel

func _ready() -> void:
	set_all_resources({"coal": 0, "iron": 0, "copper": 0, "fuel": 0, "rocket_parts": 0})
	set_power(0)
	set_pollution(0.0)
	set_rocket_status("Rocket: not built")
	set_message("Press B to build a rocket.")

func set_all_resources(resources: Dictionary) -> void:
	coal_label.text = "Coal: %d" % resources.get("coal", 0)
	iron_label.text = "Iron: %d" % resources.get("iron", 0)
	copper_label.text = "Copper: %d" % resources.get("copper", 0)
	fuel_label.text = "Fuel: %d" % resources.get("fuel", 0)
	parts_label.text = "Parts: %d" % resources.get("rocket_parts", 0)

func set_resource(resource_type: String, amount: int) -> void:
	match resource_type:
		"coal": coal_label.text = "Coal: %d" % amount
		"iron": iron_label.text = "Iron: %d" % amount
		"copper": copper_label.text = "Copper: %d" % amount
		"fuel": fuel_label.text = "Fuel: %d" % amount
		"rocket_parts": parts_label.text = "Parts: %d" % amount

func set_power(value: int) -> void:
	power_label.text = "Power: %d" % value

func set_pollution(value: float) -> void:
	pollution_label.text = "Pollution: %d%%" % int(round(value))

func set_rocket_status(status: String) -> void:
	rocket_label.text = status

func set_message(text: String) -> void:
	message_label.text = text
