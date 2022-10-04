## "Entity" as a sub-node
## must be direct child of the entity scene root node
class_name Enti2
extends Node

signal spawned()
signal died()
signal attacked(attack: Attack)


const NODE_NAME := "enti2"
const FN_SPAWNED := "_ent_spawned"
const FN_DIED := "_ent_died"


@export var alive: bool = true

var _attacks_received: Array[Attack] = []


func _init() -> void:
	name = NODE_NAME


func _enter_tree() -> void:
	assert(name == NODE_NAME, "enti2 node must be named correctly")
	get_parent().add_to_group(Groups.ENTITY)
	spawn()


func spawn() -> void:
	alive = true
	get_parent().propagate_call(FN_SPAWNED, [get_parent()])
	spawned.emit()
	Events.entity_spawned.emit(get_parent())


func attack(p_attack: Attack) -> void:
	_attacks_received.push_back(p_attack)
	attacked.emit(p_attack)
	if p_attack.is_lethal():
		kill(p_attack)


func kill(p_attack: Attack = null) -> void:
	if alive:
		alive = false
		get_parent().propagate_call(FN_DIED)
		died.emit()
		Events.entity_died.emit(get_parent(), p_attack)


static func get_enti2_or_null(node: Node) -> Enti2:
	var ent_root := node
	while ent_root:
		if ent_root.has_node(NODE_NAME):
			return ent_root.get_node(NODE_NAME)
		ent_root = ent_root.get_parent()
	return null


## Helper function to get the "entity" component for a given node.
static func get_enti2(node: Node) -> Enti2:
	assert(node.has_node(NODE_NAME))
	return node.get_node(NODE_NAME)
