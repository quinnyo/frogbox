extends Control

signal choice_next
signal choice_retry
signal choice_menu
signal choice_app_quit

enum Choice { NEXT, RETRY, MENU, APP_QUIT }


func _init() -> void:
	visible = false


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_ENTER_TREE: pass
		NOTIFICATION_EXIT_TREE: pass
		NOTIFICATION_VISIBILITY_CHANGED:
			if visible:
				get_choice_button(Choice.APP_QUIT).visible = !OS.has_feature("web")
				var focus_button := get_node("%choice_next") as BaseButton
				if focus_button.disabled:
					focus_button = get_node("%choice_retry") as BaseButton
				focus_button.grab_focus()


## Show the 'mission passed' game over screen
func show_scenario_result(result: ScenarioResult) -> void:
	set_title(result.get_outcome_text())
	set_message(result.get_message_text())
	set_choice_enabled(Choice.NEXT, result.is_passed())
	show()


func set_title(p_title: String) -> void:
	var title_label := get_node("%label_title") as Label
	title_label.text = p_title


func set_message(p_message: String) -> void:
	var title_message := get_node("%label_message") as Label
	title_message.text = p_message


func get_choice_button(choice: Choice) -> BaseButton:
	match choice:
		Choice.NEXT: return get_node("%choice_next")
		Choice.RETRY: return get_node("%choice_retry")
		Choice.MENU: return get_node("%choice_menu")
		Choice.APP_QUIT: return get_node("%choice_app_quit")
	push_error("unknown choice: %s (Choice.%s)" % [ choice, Choice.keys()[choice] ])
	return null


func set_choice_enabled(choice: Choice, enabled: bool) -> void:
	var button := get_choice_button(choice)
	if button:
		button.disabled = !enabled


func _on_choice_next_pressed() -> void:
	hide()
	choice_next.emit()


func _on_choice_retry_pressed() -> void:
	hide()
	choice_retry.emit()


func _on_choice_menu_pressed() -> void:
	hide()
	choice_menu.emit()


func _on_choice_app_quit_pressed() -> void:
	hide()
	if choice_app_quit.get_connections().is_empty():
		get_tree().quit()
	else:
		choice_app_quit.emit()
