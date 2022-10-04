extends Node2D


var _is_following: bool

func _process(_delta: float) -> void:
	var following := Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	if _is_following != following:
		_is_following = following
		queue_redraw()

	if _is_following:
		global_position = get_global_mouse_position()


func _draw() -> void:
	var color := Color(0.2, 0.2, 0.2, 0.5)
	if _is_following:
		color = Color(0.2, 0.8, 0.2)

	var radius := 16.0
	draw_arc(Vector2(), radius * 0.8, 0, TAU, 18, color)
	draw_line(Vector2.UP * radius, Vector2.DOWN * radius, color)
	draw_line(Vector2.LEFT * radius, Vector2.RIGHT * radius, color)
