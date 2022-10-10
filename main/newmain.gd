extends Node

## Emitted when scenario ends (win/lose)
signal scenario_complete(result: ScenarioResult)
## Emitted when setting the stage and should be covered/hidden.
signal scenario_loading()
## Emitted when the stage has been set and can be presented.
signal scenario_ready()
## Emitted when scenario action starts (i.e. player can play).
signal scenario_action()


enum ScenarioState { VOID, SETUP, RUNNING, COMPLETE }

@export var max_curtain_close_secs := 0.3
@export var max_curtain_open_secs := 0.5

var scenario_state := ScenarioState.VOID
var hero: Node2D
var map: Map

@onready var stage := $stage as GameStage
@onready var notifications: Notifications = get_node("%notifications")

var _result: ScenarioResult
var _start_game_requested := true
var _game_starting := false


func _ready() -> void:
	Events.entity_died.connect(_on_entity_died)


func _input(event: InputEvent) -> void:
	if event.is_action_released("quick_load", true):
		start_game()
	elif event.is_action_released("ragequit", true):
		get_tree().quit()


func _process(_delta: float) -> void:
	if _start_game_requested && !_game_starting:
		_start_game_requested = false
		_start_game()


## Request to (re)enter the game/scenario as configured.
func start_game() -> void:
	_start_game_requested = true


### Request to enter the main menu
#func open_menu() -> void:
#	pass


func _start_game() -> void:
	_game_starting = true
	_result = null
	scenario_state = ScenarioState.SETUP
	scenario_loading.emit()

	# wait for curtain before clearing stage
	await get_tree().create_timer(max_curtain_close_secs).timeout
	stage.clear()

	# load & spawn map
	var map_scn := preload("res://content/maps/test-03.tscn")
	map = map_scn.instantiate() as Map
	stage.add_to_stage(map)
	map.pini.connect(_on_map_pini)
	while !map.is_map_ready():
		# ensure map is ready, we need the spawn point from it.
		await get_tree().process_frame

	# load & spawn hero avatar
	var hero_scn := preload("res://entity/frog2/frog2.tscn")
	hero = hero_scn.instantiate() as Node2D
	stage.add_to_stage(hero)
	var spawn_point := map.get_spawn_point()
	hero.global_transform = spawn_point.get_spawn_transform() if spawn_point else map.global_transform

	# load & spawn default camera
	stage.add_default_camera()

	# disable input until game starts proper
	stage.set_avatar_control_enabled(false)
	_game_starting = false
	scenario_ready.emit()

	# wait for curtain transition & start game
	await get_tree().create_timer(max_curtain_open_secs).timeout
	scenario_state = ScenarioState.RUNNING
	scenario_action.emit()
	stage.set_avatar_control_enabled(true)


func _scenario_complete(result: ScenarioResult) -> void:
	scenario_state = ScenarioState.COMPLETE
	stage.set_avatar_control_enabled(false)
	scenario_complete.emit(result)


func _on_entity_died(node: Node, attack: Attack) -> void:
	if node == hero:
		var title := "you died"
		var message := "try again?"
		if !is_instance_valid(attack):
			title = "died mysteriously"
		else:
			title = attack.get_explanation_text()
			if attack.perpetrator_class == "toad":
				message = "cane toads are bad."

		print("scenario failed: hero died")
		_scenario_complete(ScenarioResult.new().failed(title).message(message))


func _on_map_pini(entity: Node2D) -> void:
	if entity == hero:
		var outcome := ""
		var message := "you frogfound your frogfriends"
		_scenario_complete(ScenarioResult.new().passed(outcome).message(message))


func _on_game_over_choice_retry() -> void:
	start_game()


func _on_game_over_choice_menu() -> void:
	start_game()


func _on_game_over_choice_next() -> void:
	notifications.notify_send("Next level?", "there is no next level, sorry!")
	start_game()
