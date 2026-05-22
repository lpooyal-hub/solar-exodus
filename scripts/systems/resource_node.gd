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
	if $Area2D/CollisionShape2D.shape is CircleShape2D:
		$Area2D/CollisionShape2D.shape.radius = radius
	$Area2D.connect("body_entered", Callable(self, "_on_body_entered"))
	update()

func set_resource_type(value: String) -> void:
	resource_type = value
	update()

func set_amount(value: int) -> void:
	amount = max(value, 1)
	update()

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D:
		emit_signal("collected", resource_type, amount)
		queue_free()

func _draw() -> void:
	var fill = RESOURCE_COLORS.get(resource_type, Color(0.5, 0.5, 0.5))
	draw_circle(Vector2.ZERO, radius, fill)
	draw_circle(Vector2.ZERO, radius * 0.8, Color(1, 1, 1, 0.1))
	draw_string(FontServer.get_default_font(), Vector2(-radius * 0.4, 4), str(amount), Color(1, 1, 1, 0.85))
