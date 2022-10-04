extends Node2D


@export var water_count: int = 0:
	set(w):
		if w != water_count:
			water_count = w
			queue_redraw()


@onready var canvas_ref: Node2D = get_node_or_null("canvas_ref") as Node2D


func _draw() -> void:
	_draw_drops(water_count)


func set_water_count(water: int) -> void:
	water_count = water


func _draw_drops(count: int) -> void:
	if canvas_ref:
		draw_set_transform_matrix(canvas_ref.transform)
	else:
		draw_set_transform_matrix(Transform2D(-PI / 4.0, Vector2(1.2, 0.9), deg_to_rad(5.0), Vector2(-9.0, 2.0)))

	var radius := 2.0
	var centre := Vector2.ZERO
	for i in range(count):
		centre.y = -radius * 2.0 if i % 2 else 0.0
		draw_circle(centre - Vector2(0.5, 0.0), radius + 0.5, Color(Color.ALICE_BLUE, 0.4))
		draw_circle(centre, radius, Color(Color.PALE_TURQUOISE, 0.6))
		centre.x += radius
