extends Node2D

signal collected(resource_type: String, amount: int)

@export var resource_type: String = "coal"
@export var amount: int = 6
@export var radius: float = 18.0

const RESOURCE_COLORS := {
	"coal": Color(0.16, 0.16, 0.18),
	"iron": Color(0.47, 0.40, 0.28),
	"copper": Color(0.85, 0.54, 0.30),
	"fuel": Color(0.34, 0.70, 0.98),
	"rocket_parts": Color(0.85, 0.80, 0.45)
}

func _ready() -> void:
	var collision_shape = $Area2D/CollisionShape2D
	var shape = CircleShape2D.new()
	shape.radius = radius
	collision_shape.shape = shape
	$Area2D.connect("body_entered", Callable(self, "_on_body_entered"))
	_request_redraw()

func set_resource_type(value: String) -> void:
	resource_type = value
	_request_redraw()

func set_amount(value: int) -> void:
	amount = max(value, 1)
	_request_redraw()

func get_type() -> String:
	return resource_type

func get_amount() -> int:
	return amount

func collect(collected_amount: int) -> void:
	amount -= collected_amount
	if amount <= 0:
		queue_free()
	else:
		_request_redraw()

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D:
		emit_signal("collected", resource_type, amount)
		queue_free()

func _draw() -> void:
	var fill = RESOURCE_COLORS.get(resource_type, Color(0.5, 0.5, 0.5))
	draw_circle(Vector2.ZERO, radius, fill)
	draw_circle(Vector2.ZERO, radius * 0.72, Color(1, 1, 1, 0.16))
	draw_circle(Vector2.ZERO, radius, Color(1, 1, 1, 0.4), 2)
	# draw_string removed for compatibility; avoid font-related errors during redraw

func _request_redraw() -> void:
	call_deferred("queue_redraw")
