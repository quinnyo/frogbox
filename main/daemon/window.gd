## daemon/window.gd
## Manage game window
extends Node

const PROJECT_MAX_FPS := "application/run/max_fps"
const PROJECT_MAX_FPS_UNFOCUSED := "quinn/display/max_fps_unfocused"


func _ready() -> void:
	# Correct size & floating state -- workaround for some tiling window managers.
	# Make window unresizable in ProjectSettings, allow resizing once window created:
	get_tree().root.unresizable = false


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_FOCUS_IN:
			Engine.max_fps = get_max_fps()
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			var fps := get_max_fps_unfocused()
			if fps > 0:
				Engine.max_fps = fps


func get_max_fps() -> int:
	if ProjectSettings.has_setting(PROJECT_MAX_FPS):
		return ProjectSettings.get_setting(PROJECT_MAX_FPS)
	else:
		return 0


func get_max_fps_unfocused() -> int:
	if ProjectSettings.has_setting(PROJECT_MAX_FPS_UNFOCUSED):
		return ProjectSettings.get_setting(PROJECT_MAX_FPS_UNFOCUSED)
	else:
		return 0
