extends AnimatedSprite2D


var idle_anim := "default"


func _on_frog_look_y_changed(look_y: int) -> void:
	match look_y:
		0: idle_anim = "default"
		-1: idle_anim = "look_up"
		1: idle_anim = "look_down"
		_: idle_anim = "default"
	play(idle_anim)


func _on_frog_flip_h_changed(flip: bool) -> void:
	scale.x = -1 if flip else 1
#	flip_h = flip
