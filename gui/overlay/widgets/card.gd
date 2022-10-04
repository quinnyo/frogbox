extends PanelContainer


func get_heading_label() -> Label:
	return get_node("%heading") as Label


func get_body_label() -> Label:
	return get_node("%body") as Label


func setup(heading: String, body: String) -> void:
	get_heading_label().text = heading
	get_body_label().text = body
