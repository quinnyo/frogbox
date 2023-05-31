extends Area2D
class_name Zone2D

signal entity_entered(node: Node2D)
signal entity_exited(node: Node2D)

enum { ZONE_NORMAL, ZONE_WATER, ZONE_WORLD_BOUND }

@export var type := ZONE_NORMAL

## Name of method to call on nodes detected entering the zone
@export var fn_entered_zone = "_entered_zone"
## Name of method to call on nodes detected exiting the zone
@export var fn_exited_zone = "_exited_zone"

## If true, add detected nodes to the zone group
@export var zone_group_enabled := false
## The name of the group that detected nodes will be added to (if zone_group_enabled)
@export var zone_group_name := ""


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(Groups.ENTITY):
		entity_entered.emit(body)
	if zone_group_enabled:
		assert(!zone_group_name.is_empty())
		body.add_to_group(zone_group_name)
	if body.has_method(fn_entered_zone):
		body.call(fn_entered_zone, self)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group(Groups.ENTITY):
		entity_exited.emit(body)
	if body.is_in_group(zone_group_name):
		body.remove_from_group(zone_group_name)
	if body.has_method(fn_exited_zone):
		body.call(fn_exited_zone, self)


func _on_area_entered(area: Area2D) -> void:
	_on_body_entered(area)


func _on_area_exited(area: Area2D) -> void:
	_on_body_exited(area)
