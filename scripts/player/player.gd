extends CharacterBody2D

@export var move_speed: float = 180.0
@export var walk_sway_amount: float = 0.12
@export var walk_sway_speed: float = 10.0
@export var idle_bob_amount: float = 0.04
@export var idle_bob_speed: float = 2.5

var animation_timer: float = 0.0
var player_sprite: Sprite2D = null
var player_body: Polygon2D = null

func _ready() -> void:
	_setup_input_actions()
	if has_node("Sprite2D"):
		player_sprite = $Sprite2D
	if has_node("Polygon2D"):
		player_body = $Polygon2D
		player_body.polygon = [Vector2(-14, -10), Vector2(14, 0), Vector2(-14, 10)]
		player_body.color = Color(0.20, 0.78, 1.00, 1.0)

func _physics_process(delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction == Vector2.ZERO:
		direction.x = int(Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT)) - int(Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT))
		direction.y = int(Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN)) - int(Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP))
		if direction != Vector2.ZERO:
			direction = direction.normalized()

	if direction != Vector2.ZERO:
		velocity = direction * move_speed
		move_and_slide()
		_move_visuals(delta, true)
	else:
		velocity = Vector2.ZERO
		_move_visuals(delta, false)

func _move_visuals(delta: float, moving: bool) -> void:
	animation_timer += delta
	if moving:
		var sway = sin(animation_timer * walk_sway_speed) * walk_sway_amount
		if player_body != null:
			player_body.rotation = sway
		if player_sprite != null:
			player_sprite.scale = Vector2.ONE * (1.0 + abs(sin(animation_timer * walk_sway_speed * 0.5)) * idle_bob_amount)
	else:
		if player_body != null:
			player_body.rotation = lerp(player_body.rotation, 0.0, 0.12)
		if player_sprite != null:
			player_sprite.scale = Vector2.ONE * (1.0 + sin(animation_timer * idle_bob_speed) * idle_bob_amount)

func get_debug_input_state() -> String:
	var active: Array = []
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		active.append("Left")
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		active.append("Right")
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		active.append("Up")
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		active.append("Down")
	return ", ".join(active) if active.size() > 0 else "None"

func get_debug_velocity() -> Vector2:
	return velocity

func _setup_input_actions() -> void:
	var key_map := {
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"move_up": [KEY_W, KEY_UP],
		"move_down": [KEY_S, KEY_DOWN]
	}
	for action_name in key_map.keys():
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
		for key_code in key_map[action_name]:
			var ev := InputEventKey.new()
			ev.keycode = key_code
			if not InputMap.event_is_action(ev, action_name):
				InputMap.action_add_event(action_name, ev)
