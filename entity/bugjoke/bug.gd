extends Area2D


@onready var _sprite := get_node("bug") as AnimatedSprite2D
@onready var _timer := get_node("timer") as Timer

var _rando := RandomNumberGenerator.new()
var _noise := FastNoiseLite.new()
var _direction := Vector2.DOWN
var _alive := true


func _shuffle() -> void:
	if !_alive:
		position = Vector2.ZERO
		_alive = true
	_direction = Vector2.from_angle(_rando.randf() * TAU)
	_timer.wait_time = _rando.randf_range(1.5, 4.5)
	_sprite.speed_scale = 1.0
	modulate = Color.WHITE
	_sprite.playing = true


func _kill() -> void:
	_alive = false
	_timer.start(10.0)
	_sprite.speed_scale = 0.5


func _ready() -> void:
	_sprite.playing = true
	_rando.randomize()

	_noise.seed = _rando.randi()
	_noise.fractal_octaves = 4


func _process(delta: float) -> void:
	_sprite.flip_v = !_alive
	if _alive:
		modulate.a = 1.0
		var alpha := _noise.get_noise_2dv(global_position)
		var move := _direction.rotated(alpha * PI)
		position += move * 25.0 * (2.0 - absf(alpha)) * delta
	else:
		position += Vector2.DOWN * 5.0 * delta
		modulate.a -= 0.2 * delta
		_sprite.speed_scale -= 0.25 * delta


func _on_timer_timeout() -> void:
	_shuffle()


func _entered_zone(zone: Zone2D) -> void:
	if zone.type == Zone2D.ZONE_WATER:
		_kill()


func _exited_zone(zone: Zone2D) -> void:
	if zone.type == Zone2D.ZONE_WORLD_BOUND:
		_kill()
