extends Camera2D

@export var target_path: NodePath
@export var smoothing_speed: float = 6.0

var target: Node = null

func _ready() -> void:
	if target_path != null and has_node(target_path):
		target = get_node(target_path)
	if target:
		make_current()

func _process(delta: float) -> void:
	if target == null:
		return
	global_position = global_position.lerp(target.global_position, clamp(smoothing_speed * delta, 0.0, 1.0))
