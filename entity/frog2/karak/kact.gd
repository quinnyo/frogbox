class_name Kact
extends Resource

enum Status { ERROR, INIT, RUNNING, COMPLETE, }

var body: KarakBody2D = null

var status: Status:
	get: return _status

var _status := Status.INIT
var _tick := -1


func is_active() -> bool:
	return status == Status.INIT || status == Status.RUNNING


func is_running() -> bool:
	return status == Status.RUNNING


func bind(p_body: KarakBody2D) -> void:
	body = p_body


func is_bound() -> bool:
	return is_instance_valid(body)


func get_ticks() -> int:
	return _tick


func start() -> void:
	assert(is_bound())
	_status = Status.RUNNING
	_start()


func think() -> void:
	_tick += 1
	_think()


func integrate(state: PhysicsDirectBodyState2D) -> void:
	_integrate(state)


func stop() -> void:
	if _status == Status.RUNNING:
		_stop()
		_status = Status.COMPLETE


func _start() -> void:
	pass


func _think() -> void:
	pass


func _integrate(_state: PhysicsDirectBodyState2D) -> void:
	pass


func _stop() -> void:
	pass


func _get_kact_name() -> String:
	var script: Script = get_script()
	var name := "?"
	if is_instance_valid(script):
		name = script.resource_path.get_file()
	return "Kact<%s>" % [ name ]


func _to_string() -> String:
	return "[%s:%s]" % [ _get_kact_name(), get_instance_id() ]
