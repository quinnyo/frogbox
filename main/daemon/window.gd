## daemon/window.gd
## Manage game window
extends Node

const SETT_TARGET_FPS := "quinn/display/target_fps"
const SETT_UNFOCUSED_TARGET_FPS := "quinn/display/unfocused_target_fps"


func _ready() -> void:
	Engine.target_fps = get_target_fps()

	# Correct size & floating state -- workaround for some tiling window managers.
	# Make window unresizable in ProjectSettings, allow resizing once window created:
	get_tree().root.unresizable = false


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_APPLICATION_FOCUS_IN:
			Engine.target_fps = get_target_fps()
		NOTIFICATION_APPLICATION_FOCUS_OUT:
			var fps := get_unfocused_target_fps()
			if fps > 0:
				Engine.target_fps = fps


func get_target_fps() -> int:
	if ProjectSettings.has_setting(SETT_TARGET_FPS):
		return ProjectSettings.get_setting(SETT_TARGET_FPS)
	else:
		return 0


func get_unfocused_target_fps() -> int:
	if ProjectSettings.has_setting(SETT_UNFOCUSED_TARGET_FPS):
		return ProjectSettings.get_setting(SETT_UNFOCUSED_TARGET_FPS)
	else:
		return 0
