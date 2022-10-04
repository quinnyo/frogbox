@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run() -> void:
	var tex: Texture2D = load("res://mess/props/ground_noise_tex.tres") as Texture2D
	if tex:
		var img := tex.get_image()
		img.save_png("/tmp/ground_noise.png")
	pass
