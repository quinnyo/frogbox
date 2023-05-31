extends AnimatedSprite2D

@export var anim_idle := "default"
@export var anim_action := "call_high"


var _anim_action: String
var _loops := 0
var _idle_time := 0.0


func _ready() -> void:
	action(1)


func _process(delta: float) -> void:
	if _idle_time > 0.0:
		_idle_time -= delta


func action(loops: int) -> void:
	play(anim_action)
	_anim_action = anim_action
	_loops = loops
	var s := snappedf(randfn(1.0, 0.15), 0.1)
	speed_scale = maxf(s, 0.5)


func _on_animation_finished() -> void:
	if animation == _anim_action:
		if _loops > 0:
			_loops -= 1
			if _loops == 2:
				speed_scale /= 2.0
		else:
			play(anim_idle)
			_idle_time = randf_range(2.0, 5.0)
	elif _idle_time <= 0.0:
		var n := randi_range(2, 9)
		action(n)
