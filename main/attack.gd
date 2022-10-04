class_name Attack
extends RefCounted

enum Type { GENERIC, WORLD, CONTACT_DAMAGE }

var perpetrator_class: String = ""
var type: Type = Type.GENERIC

var _target: Node
var _perpetrator: Node
var _explanation_text: String = ""


func set_explanation_text(p_text: String) -> void:
	_explanation_text = p_text


func bind(p_perpetrator: Node, p_target: Node) -> void:
	_perpetrator = p_perpetrator
	_target = p_target


func is_lethal() -> bool:
	return true


func get_perpetrator_text() -> String:
	if is_instance_valid(_perpetrator):
		return str(_perpetrator.name).capitalize()
	return "<Ghost>"


func get_explanation_text() -> String:
	return _explanation_text
