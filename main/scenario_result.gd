class_name ScenarioResult
extends RefCounted

enum Outcome { NONE, PASSED, FAILED }

var _outcome: Outcome = Outcome.NONE
var _custom_outcome: String = ""
var _custom_outcome_enable: bool = false
var _message: String = ""


## Set message -- text to explain the outcome (or its cause) or flavour text for game over screen.
func message(p_message: String) -> ScenarioResult:
	_message = p_message
	return self


## Set the outcome to one of the standard `Outcome` variants. Optionally, supply
## a custom outcome text as `p_custom` (will be converted to String).
func outcome(p_outcome: Outcome, p_custom: Variant = null) -> ScenarioResult:
	_outcome = p_outcome
	if p_custom:
		_custom_outcome_enable = true
		_custom_outcome = str(p_custom)
	else:
		_custom_outcome_enable = false
	return self


func failed(p_custom: Variant = null) -> ScenarioResult:
	return outcome(Outcome.FAILED, p_custom)


func passed(p_custom: Variant = null) -> ScenarioResult:
	return outcome(Outcome.PASSED, p_custom)


func is_passed() -> bool:
	return _outcome == Outcome.PASSED


func get_message_text() -> String:
	return _message


func get_outcome_text() -> String:
	if _custom_outcome_enable:
		return _custom_outcome

	match _outcome:
		Outcome.PASSED: return "Passed!"
		Outcome.FAILED: return "Failed!"
		_: return "N/A"
